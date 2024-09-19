{ config, ... }:

{
  services.nginx.virtualHosts."db.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.emile.ports.nocodb}";
      };
    };
  };
  virtualisation.oci-containers = {
    containers = {
      "noco" = {
        image = "nocodb/nocodb:latest";
        volumes = [ "nocodb:/usr/app/data" ];
        ports = [ "${toString config.emile.ports.nocodb}:8080" ];
      };
    };
  };
}
