{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.emile.r2wars-web;
in
with lib;
{
  options.services.emile.r2wars-web = {
    enable = mkEnableOption "Enable r2wars-web";

    # ip and port to listen on
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

    # env vars with secrets to set
    sessionKey = mkOption {
      type = types.str;
      default = "";
      example = "abc1Itheich4aeQu9Ouz7ahcaiVoogh9";
      description = "The sessionKey passed to the bin as an env var";
    };

    salt = mkOption {
      type = types.str;
      default = "";
      example = "OhD0ki5aLieMoowah8Eemaim2beaf2Na";
      description = "The salt passed to the bin as an env var";
    };

    # paths to files
    logfilePath = mkOption {
      type = types.str;
      default = "/var/lib/r2wars.log";
      example = "/var/lib/r2wars.log";
      description = "The path to the logfile";
    };

    databasePath = mkOption {
      type = types.str;
      default = "/var/lib/main.db";
      example = "/var/lib/main.db";
      description = "The path to the main database";
    };

    sessiondbPath = mkOption {
      type = types.str;
      default = "/var/lib/sessions.db";
      example = "/var/lib/sessions.db";
      description = "The path to the sessions database";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.r2wars-web = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };
      environment = {
        SESSION_KEY = cfg.sessionKey;
        SALT = cfg.salt;
        VERSION = pkgs.r2wars-web.version;
      };
      path = [ pkgs.radare2 ];
      serviceConfig.ExecStart = "${pkgs.r2wars-web}/bin/r2wars-web -h ${cfg.host} -p ${toString cfg.port} --logfilepath ${cfg.logfilePath} --databasepath ${cfg.databasePath} --sessiondbpath ${cfg.sessiondbPath} --templates ${pkgs.r2wars-web}/templates";
    };
  };
}
