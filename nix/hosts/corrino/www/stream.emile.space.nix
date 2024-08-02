{ config, ... }:

{
  services.nginx.virtualHosts."stream.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.owncast.port}";
        proxyWebsockets = true;
      };
    };
  };

  services.owncast = {
    enable = true;
    openFirewall = true;
    listen = "0.0.0.0";
    dataDir = "/var/lib/owncast";
    rtmp-port = config.emile.ports.stream_rtmp;
    port = config.emile.ports.stream; # web interface
  };
}
