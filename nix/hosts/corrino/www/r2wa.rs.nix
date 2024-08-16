{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."r2wa.rs" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.emile.ports.r2wars-web}";
      };
    };
  };

  environment.systemPackages = with pkgs; [ radare2 ];

  # deploy:
  # - push code
  # - build in order to get the new hash (nix build .#r2war-sweb)
  # - update hash in the package (//nix/pkgs/r2wars-web/default.nix)
  # - deploy

  services.emile.r2wars-web = {
    enable = true;

    host = "127.0.0.1";
    port = config.emile.ports.r2wars-web;

    # TODO(emile): change these when going live
    sessionKey = "insecuretmpkey";
    salt = "insecuresalt";

    logfilePath = "/var/lib/r2wars/r2wars.log";
    databasePath = "/var/lib/r2wars/main.db";
    sessiondbPath = "/var/lib/r2wars/session.db";
  };
}
