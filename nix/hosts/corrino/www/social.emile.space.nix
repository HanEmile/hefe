{ config, pkgs, ... }:

{

  # the reverse proxy to gotosocial
  services.nginx.virtualHosts."social.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.emile.ports.gotosocial}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 40M;
        '';
      };

    };
  };

  # Redirects from emile.space to social.emile.space
  # Without this, other instances have problems getting from the username
  #   @hanemile@emile.space to the host social.emile.space
  # https://docs.gotosocial.org/en/latest/advanced/host-account-domain/
  services.nginx.virtualHosts."emile.space" = {
    locations = {
      "/.well-known/webfinger".extraConfig = ''
        rewrite ^.*$ https://social.emile.space/.well-known/webfinger permanent;
      '';

      "/.well-known/host-meta".extraConfig = ''
        rewrite ^.*$ https://social.emile.space/.well-known/host-meta permanent;
  		'';

      "/.well-known/nodeinfo".extraConfig = ''
        rewrite ^.*$ https://social.emile.space/.well-known/nodeinfo permanent;
  		'';
    };
  };

  age.secrets.gotosocial_oidc_client_secret.owner = "authelia-main";
  age.secrets.gotosocial_oidc_client_secret.group = "authelia-main";
  
  # auth via authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "gotosocial";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      client_secret = "{{ secret \"${config.age.secrets.gotosocial_oidc_client_secret.path}\" }}";

      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [ "https://social.emile.space/auth/callback" ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      grant_types = [
        "refresh_token"
        "authorization_code"
      ];
      response_types = [ "code" ];
      response_modes = [
        "form_post"
        "query"
        "fragment"
      ];
    }
  ];

  services.gotosocial = {
    enable = true;
    package = pkgs.gotosocial;
    settings = {
      host = "social.emile.space";
      port = config.emile.ports.gotosocial;
      bind-address = "127.0.0.1";
      account-domain = "emile.space";
      db-type = "sqlite";
      db-address = "/var/lib/gotosocial/database.sqlite";
      protocol = "https";
      storage-local-base-path = "/var/lib/gotosocial/storage";
      oidc-idp-name = "authelia";
      oidc-client-id = "gotosocial";
      advanced-rate-limit-requests = 0;
      accounts-allow-custom-css = true;
    };
    environmentFile = config.age.secrets.gotosocial_environment_file.path;
  };

  systemd.services.gotosocial = {
    after = [ "authelia-main.service" ];
    serviceConfig = {
      Restart = "on-failure";
    };
  };

  services.restic.backups."corrino" = {
    paths = [ "/var/lib/gotosocial" ];
  };

  services.restic.backups."gotosocial" = {
    repository = "/mnt/storagebox-bx11/gotosocial";
    paths = [ "/var/lib/gotosocial" ];
    passwordFile = config.age.secrets.restic_password.path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
