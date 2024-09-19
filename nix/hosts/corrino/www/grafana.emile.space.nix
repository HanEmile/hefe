{ config, ... }:

{
  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana_env_vars.path;

  services = {
    nginx.virtualHosts = {
      "grafana.emile.space" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
          proxyWebsockets = true;
        };
      };
    };

    authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        id = "Grafana";

        # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
        secret = "$pbkdf2-sha512$310000$S.RE0jcmr7Sn/tjJDNxV/A$1tsYhQ/YEcVfE4JyzszHemrcUqy.84Fb6xVSmz87if5C9N46Mz2lRWB5l8s4EIrLsiumPnt4HQMkYZ4MoovJzA";
        public = false;
        authorization_policy = "two_factor";
        redirect_uris = [ "https://grafana.emile.space/login/generic_oauth" ];
        scopes = [
          "openid"
          "email"
          "profile"
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

    # example from md.emile.space
    # CMD_OAUTH2_PROVIDERNAME=Authelia
    # CMD_OAUTH2_CLIENT_ID=HedgeDoc
    # CMD_OAUTH2_CLIENT_SECRET=
    # CMD_OAUTH2_SCOPE=openid email profile
    # CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR=sub
    # CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR=name
    # CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR=email
    # CMD_OAUTH2_USER_PROFILE_URL=https://sso.emile.space/api/oidc/userinfo
    # CMD_OAUTH2_TOKEN_URL=https://sso.emile.space/api/oidc/token
    # CMD_OAUTH2_AUTHORIZATION_URL=https://sso.emile.space/api/oidc/authorize
    # CMD_DOCUMENT_MAX_LENGTH=1000000

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = config.emile.ports.grafana;
          domain = "grafana.emile.space";
          root_url = "https://grafana.emile.space/";
        };

        "auth.generic_oauth" = let
          sso = "https://sso.emile.space/api/oidc";
        in {
          enabled = true;
          client_id = "Grafana";

          # [auth.generic_oauth]
          # client_secret = ... 
          #   set in env var as 
          #   GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET 
          client_secret = "set in env var this is just a placeholder";

          token_url = "${sso}/token";
          auth_url = "${sso}/authorization";
          api_url = "${sso}/userinfo";
          scopes = [
            "openid"
            "email"
            "profile"
          ];
          use_refresh_token = true;

          # scopes = "openid email profile offline_access roles";
          # email_attribute_path = "email";
          # login_attribute_path = "username";
          # name_attribute_path = "full_name";
          # role_attribute_path = "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";

          role_attribute_path = "contains(groups[*], 'admin') && 'Admin' || contains(groups[*], 'editor') && 'Editor' || 'Viewer'";
        };
      };

      provision = {
        datasources = {
          settings = {
            datasources = [
              {
                url = "http://localhost:${toString config.services.prometheus.port}";
                type = "prometheus";
                name = "Prometheus";
                editable = false;
                access = "proxy"; # server = "proxy", browser = "direct"
              }
              {
                name = "loki";
                url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
                type = "loki";
              }
            ];
          };
        };
      };
    };
  };
}
