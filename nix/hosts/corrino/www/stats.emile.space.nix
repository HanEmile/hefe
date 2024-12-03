{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."stats.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.services.goatcounter.port}";
      };
    };
  };

  services.goatcounter = {
    enable = true;
    package = pkgs.goatcounter;

    proxy = true;
    address = "[::1]";
    port = config.emile.ports.goatcounter;
  };
}
