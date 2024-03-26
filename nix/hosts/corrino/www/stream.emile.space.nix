{ config, ... }:

let
  ports = import ../ports.nix;
in {
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
    rtmp-port = ports.stream_rtmp;
    port = ports.stream; # web interface
  };
}
