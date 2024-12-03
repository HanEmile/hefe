{ config, pkgs, ... }:

{
  services.nginx.clientMaxBodySize = "100m";
  services.nginx.virtualHosts."photo.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}";
        proxyWebsockets = true;
      };
    };
  };

  # auth via authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      id = "Immich";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      secret = "$pbkdf2-sha512$310000$iCgyAKjoYH9UKADProvbgw$LjrYkX1MjjtSXWDkxDjyp3NkLLuLVvKVwy3o8/Rw.8Z8b6yCkPWdBCothuCMlaGcgfG/zLWM6lRV4BrXVZpkig";
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

      token_endpoint_auth_method = "client_secret_basic";

      # might be needed since the upgrade to nixos-24.11 and the resulting
      # 4.37.5 -> 4.38.17 upgrade
      # token_endpoint_auth_method = "client_secret_post";
    }
  ];


  services.immich = {
    enable = true;
    package = pkgs.immich;
    mediaLocation = "/var/lib/immich";
    secretsFile = config.age.secrets.immich_secrets_file.path;

    host = "127.0.0.1";
    port = config.emile.ports.immich;

    machine-learning = {
      enable = false;
      environment = {
        MACHINE_LEARNING_MODEL_TTL = "600";
      };
    };
  };
}
