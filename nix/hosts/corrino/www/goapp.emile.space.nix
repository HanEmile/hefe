{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."goapp.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://${config.services.emile.goapp-frontend.host}:${toString config.services.emile.goapp-frontend.port}";
      };
    };
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      id = "goapp";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      secret = "$pbkdf2-sha512$310000$/Ht5DUFmIeu/7Ty2PWHXnw$.uJIN1vmZMyGjCAoA0PzUcVaTMIH36AK80KvOZAHVXgLr1Y9ZOrRjoiwK.srHAO29mrcw1BNpCjFTYdWOoympg";
      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [
        # "http://localhost:8080/oauth2/callback"
        "https://goapp.emile.space/oauth2/callback"
      ];
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
      token_endpoint_auth_method = "client_secret_post";
    }
  ];

  environment.systemPackages = with pkgs; [ goapp-frontend ];

  # deploy:
  # - push code
  # - build in order to get the new hash (nix build .#goapp-frontend-pkg)
  # - update hash in the package (//nix/templates/goapp/frontent/default.nix)
  # - deploy

  # services.emile.goapp-frontend = {
  #   enable = true;
  #   package = pkgs.goapp-frontend;

  #   host = "127.0.0.1";
  #   port = config.emile.ports.goapp-frontend;
  #   public-url = "https://goapp-frontend.emile.space/";

  #   oidc = {
  #     id = "goapp-frontend";
  #     issuer = "https://sso.emile.space";
  #     cookie-name = "oidc-client";
  #     scopes = [ "openid" "profile" "email" "groups" ];
  #     secret-path = "/run/goapp-frontend_oidc_secret";
  #   };

  #   # TODO(emile): change these when going live
  #   session-key-path = config.age.secrets.goapp-frontend_oidc_secret.path;

  #   logfile-path = "/var/log/goapp-frontend.log";
  #   database-path = "/var/lib/goapp-frontend/main.db";
  #   sessiondb-path = "/var/lib/goapp-frontend/session.db";
  # };
}
