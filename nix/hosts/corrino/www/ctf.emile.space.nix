{ ... }:

let
  ports = import ../ports.nix;
in {
  services.nginx.virtualHosts."ctf.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString ports.ctf}";
      };
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "ctfd" = {
        image = "ctfd/ctfd";
        ports = [
          "${toString ports.ctf}:8000"
        ];
      };
    };
  };
}
