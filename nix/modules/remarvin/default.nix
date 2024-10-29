{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.emile.remarvin;
in
with lib;
{
  options.services.emile.remarvin = {
    enable = mkEnableOption "Enable remarvin";

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
    username = mkOption {
      type = types.str;
      default = "";
      example = "remarvin";
      description = "The username of the bot (without @ or homeserver)";
    };

    homeserver = mkOption {
      type = types.str;
      default = "";
      example = "matrix.org";
      description = "The homeserver to use";
    };

    accesstoken = mkOption {
      type = types.str;
      default = "";
      example = "syt_bWFy2mluX34lc3Qx_VARzpUOQIzyzCHunCDnd_1hbPka";
      description = "The accesstoken used to authenticat (element web > settings > help & about > advanced > access token)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.remarvin = {
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
      path = [ pkgs.remarvin ];
      serviceConfig.ExecStart = "${pkgs.remarvin}/bin/remarvin -homeserver ${cfg.homeserver} -username ${cfg.username} -accesstoken ${cfg.accesstoken}";
    };
  };
}
