{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.emile.goapp-frontend;
in
with lib;
{
  options.services.emile.goapp-frontend = {
    enable = mkEnableOption "Enable goapp-frontend";
    package = mkPackageOption pkgs "goapp-frontend" { };

    # ip, port and external host to listen on
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "The host the service listens on";
    };
    port = mkOption {
      type = types.int;
      default = 8080;
      example = 8080;
      description = "The port the service listens on";
    };
    public-url = mkOption {
      type = types.str;
      default = "http://localhost:8080/";
      example = "https://goapp.emile.space/";
      description = ''
        The domain that the service can be reached from externally. This is used by oidc for redirects and thus should be set, as you'll probably be running this behind some kind of reverse proxy.
      '';
    };

    # the oidc config
    oidc = mkOption {
      type = types.submodule {
        options = {
          id = mkOption {
            type = types.str;
            default = "";
            example = "AiliavahweiweeG5";
            description = "The oidc id";
          };
          issuer = mkOption {
            type = types.str;
            default = "";
            example = "https://sso.emile.space";
            description = "The oidc identity provider";
          };
          cookie-name = mkOption {
            type = types.str;
            default = "oidc-client";
            example = "CookieMcCookieface";
            description = "The oidc cookie name";
          };
          scopes = mkOption {
            type = types.listOf types.str;
            default = [ "openid" "profile" "email" "groups" ];
            example = [ "openid" "profile" "email" ];
            description = "The openid scopes to request";
          };
          secret-path = mkOption {
            type = types.str;
            default = "";
            example = "/run/goapp_oidc_secret";
            description = "The path to the oidc secret";
          };
        };
      };
    };
     
    # paths to files
    session-key-path = mkOption {
      type = types.str;
      default = "";
      example = "/run/sesionkey";
      description = "The path to a file containing the sessionKey";
    };
    logfile-path = mkOption {
      type = types.str;
      default = "/var/log/goapp-frontend.log";
      example = "/var/log/goapp-frontend.log";
      description = "The path to where the logfile should be written";
    };

    database-path = mkOption {
      type = types.str;
      default = "/var/lib/goapp-frontend/main.db";
      example = "/var/lib/goapp-frontend/main.db";
      description = "The path to the main database";
    };
    sessiondb-path = mkOption {
      type = types.str;
      default = "/var/lib/goapp-frontend/sessions.db";
      example = "/var/lib/goapp-frontend/sessions.db";
      description = "The path to the sessions database";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.goapp-frontend = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 5;
        Restart = "on-failure";
      };
      environment = {
        VERSION = pkgs.goapp-frontend.version;
      };
      path = [ pkgs.goapp-frontend ];
      serviceConfig.ExecStart = ''
        ${pkgs.goapp-frontend}/bin/goapp-frontend \
          --host ${cfg.host} \
          --port ${toString cfg.port} \
          --public-url ${cfg.public-url} \
          --id ${cfg.oidc.id} \
          --issuer ${cfg.oidc.issuer} \
          --cookie-name ${cfg.oidc.cookie-name} \
          --scopes ${concatStringsSep "," cfg.oidc.scopes} \
          --oidc-secret-path ${cfg.oidc.secret-path} \
          --logfilepath ${cfg.logfile-path} \
          --databasepath ${cfg.database-path} \
          --sessiondbpath ${cfg.sessiondb-path} \
          --sessionkeypath ${cfg.session-key-path} \
          --templatespath ${pkgs.goapp-frontend}/templates
      '';
    };
  };
}
