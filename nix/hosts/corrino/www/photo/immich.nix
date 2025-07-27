{ config, pkgs, ... }:

{
  services.nginx.clientMaxBodySize = "100m";
  services.nginx.virtualHosts."photo.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      # # immich private proxy
      # "/share" = {
      #   proxyPass = "http://${config.services.immich.host}:${toString config.services.immich-public-proxy.port}";
      # };
      # "/share/*" = {
      #   proxyPass = "http://${config.services.immich.host}:${toString config.services.immich-public-proxy.port}";
      # };

      # immich
      "/" = {
        proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}";
        proxyWebsockets = true;
      };
    };
  };

  age.secrets.immich_oidc_client_secret.owner = "authelia-main";
  age.secrets.immich_oidc_client_secret.group = "authelia-main";

  # auth via authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "Immich";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      client_secret = "{{ secret \"${config.age.secrets.immich_oidc_client_secret.path}\" }}";

      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [
        "https://photo.emile.space/auth/login"
        "https://photo.emile.space/user-settings"
        "app.immich:///oauth-callback"
      ];
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      #grant_types = [
      #  "refresh_token"
      #  "authorization_code"
      #];
      #response_types = [ "code" ];
      #response_modes = [
      #  "form_post"
      #  "query"
      #  "fragment"
      #];

      # token_endpoint_auth_method = "client_secret_basic";

      # might be needed since the upgrade to nixos-24.11 and the resulting
      # 4.37.5 -> 4.38.17 upgrade
      token_endpoint_auth_method = "client_secret_post";
    }
  ];

  services.immich = {
    enable = true;
    package = pkgs.immich;
    mediaLocation = "/var/lib/immich";
    secretsFile = config.age.secrets.immich_secrets_file.path;

    host = "127.0.0.1";
    port = config.emile.ports.photo.immich;

    machine-learning = {
      enable = false;
      environment = {
        MACHINE_LEARNING_MODEL_TTL = "600";
      };
    };
  };

  # services.immich-public-proxy = {
  #   enable = true;
  #   package = pkgs.immich-public-proxy;
  #   settings = {
  #     downloadOriginalPhoto = true;
  #     showGalleryTitle = true;
  #     allowDownloadAll = 1;
  #     showHomePage = true;
  #     showMetadata = true;
  #   };
  #   port = config.emile.ports.photo.immich-public-proxy;
  #   openFirewall = false;
  #   immichUrl = "photo.emile.space";
  # };
}
