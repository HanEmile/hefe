{ ... }:

{
  services.nginx.virtualHosts."stream.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
      };
    };
  };

  services.owncast = {
    enable = true;
    openFirewall = true;
    listen = "0.0.0.0";
    dataDir = "/var/lib/owncast";
    rtmp-port = 1935;
    port = 8080; # web interface
  };
}
