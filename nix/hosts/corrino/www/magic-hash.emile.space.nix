{ config, ... }:

{
  services.nginx.virtualHosts."magic-hash.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.emile.ports.magic-hash}";
      };
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "ctfd" = {
        image = "magic-hash";
        ports = [ "${toString config.emile.ports.magic-hash}:80" ];
        environment = {

          # this is not encouraged, but should work for the weekend (this is a
          # flag, not a password, so even if it get's leaked, the worst that
          # can happen is that people could enter it somewhere)
          "FLAG" = builtins.readFile config.age.secrets.magic-hash-flag.path;
        };
      };
    };
  };
}
