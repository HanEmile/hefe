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
      secret = "$pbkdf2-sha512$310000$LPXJRoGR9RyTcaT6cADljg$FK8RV5CnKj5ano4fXmRzzvXcX/00F7k/G6nd67t.8iewpwyq8FntV4JgYZSV8AynYMxz1qnL4j3BzITLCM0KgQ";
      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [
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
  #
  # https://goapp.emile.space/oauth2/callback?code=authelia_ac_iZKCXtRMnj2yjUAmiSkg_LBWjiME2-ghE6KMkxdb6Zw.nDLgCVpu9ctH1llEKUml5rr8szd3bkZYaGa_MAOtNLI&iss=https%3A%2F%2Fsso.emile.space&scope=openid+profile+email+groups&state=random-string-here
  #
  # Unable to exchange authorization code for tokens
  #
  # unable to exchange authorization code for tokens: oauth2: "invalid_client" "Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method)."

  services.emile.goapp-frontend = {
    enable = true;
    package = pkgs.goapp-frontend;

    host = "127.0.0.1";
    port = config.emile.ports.goapp;
    public-url = "https://goapp.emile.space/";

    oidc = {
      id = "goapp";
      issuer = "https://sso.emile.space";
      cookie-name = "oidc-client";
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
      # secret-path = "/run/goapp-frontend_oidc_secret";
      secret-path = config.age.secrets.goapp_oidc_secret.path;
    };

    # TODO(emile): change these when going live
    session-key-path = config.age.secrets.goapp_oidc_secret.path;

    logfile-path = "/var/log/goapp-frontend.log";
    database-path = "/var/lib/goapp-frontend/main.db";
    sessiondb-path = "/var/lib/goapp-frontend/session.db";
  };
}
