{ config, pkgs, ... }:

let
  ports = import ../ports.nix;
in {
  services.nginx.virtualHosts."netbox.emile.space" = {
    forceSSL = true;
    enableACME = true;
    kTLS = true;

    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.netbox.port}";
      proxyWebsockets = true;
    };
    locations."/static/".root = "${config.services.netbox.dataDir}";
  };

  users.users.nginx.extraGroups = [ "netbox" ];

  environment.systemPackages = with pkgs; [ netbox ];

  services.netbox = {
    enable = true;
    package = pkgs.netbox_3_6; # nixos 23.11 now has netbox 3.6
    dataDir = "/var/lib/netbox";
    settings.ALLOWED_HOSTS = [ "*" ];
    enableLdap = false;
    settings = {};
    secretKeyFile = config.age.secrets.netbox_secret.path;
    port = ports.netbox;
    listenAddress = "[::1]";
  };

  age.secrets.netbox_secret = {
    mode = "440";
    owner = "netbox";
    group = "netbox";
  };

  #services.netbox = {
  #  enable = true;
  #  listenAddress = "[::1]";
  #  secretKeyFile = config.age.secrets.netbox_secret.path;
  #  package = pkgs.netbox.override { python3 = pkgs.python310; };
  #  # extraConfig = ''
  #  #   # REMOTE_AUTH_BACKEND = 'social_core.backends.open_id_connect.OpenIdConnectAuth'
  #  #   # SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = 'https://auth.c3voc.de'

  #  #   EXEMPT_VIEW_PERMISSIONS = ['*']
  #  # '';
  #};

  # add nginx to the netbox group so it can read /var/lib/nginx/static
  # users = {
  #   groups."netbox" = {};
  #   users = {
  #     netbox = {
  #       isNormalUser = true;
  #       group = "netbox";
  #     };
  #   };
  # };
  # users.users.nginx.extraGroups = [ "netbox" ];
}

