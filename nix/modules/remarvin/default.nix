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

    accesstokenpath = mkOption {
      type = types.str;
      default = "";
      example = "/secret/remarvin_accesstoken";
      description = "The path to the accesstoken used (element web > settings > help & about > advanced > access token)";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.remarvin = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };
      path = [ pkgs.remarvin ];
      serviceConfig.ExecStart = "${pkgs.remarvin}/bin/remarvin -homeserver ${cfg.homeserver} -username ${cfg.username} -accesstokenpath ${cfg.accesstokenpath}";
    };
  };
}
