{ ... }:

{
  services.nginx.virtualHosts."ctf.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8338";
      };
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "ctfd" = {
        image = "ctfd/ctfd";
        ports = [
          "8338:8000"
        ];
      };
    };
  };
}
