{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.emile.filebrowser;
in
with lib;
{
  options.services.emile.filebrowser = {
    enable = mkEnableOption "Enable filebrowser";

    # ip and port to listen on
    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "The address the service listens on";
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      example = 8080;
      description = "The port the service listens on";
    };

    root = mkOption {
      type = types.str;
      default = null;
      example = "/data";
      description = "The directory to serve";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.filebrowser = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };
      path = [ pkgs.filebrowser pkgs.getent ];

      # don't want the filebrowser.db to appear in the root? change it here (after --database)
      serviceConfig.ExecStart = ''${pkgs.filebrowser}/bin/filebrowser \
        -a ${cfg.address} \
        -p ${toString cfg.port} \
        --database ${cfg.root}/filebrowser.db \
        -r ${cfg.root}
      '';
    };
  };
}
