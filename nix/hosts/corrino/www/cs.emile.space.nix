# Run sourcegraph, including its entire machinery, in a container.
# Running it outside of a container is a futile endeavour for now.

# adapted from https://cs.tvl.fyi/depot/-/blob/ops/modules/sourcegraph.nix

{ ... }:

{
  services.nginx.virtualHosts."cs.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:3463";

        extraConfig = ''
          location = / {
            return 301 https://cs.emile.space/hefe;
          }

          location / {
            proxy_set_header X-Sg-Auth "Anonymous";
            proxy_pass http://localhost:7080;
          }

          location /users/Anonymous/settings {
            return 301 https://cs.emile.space;
          }
        '';
      };
    };
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.sourcegraph = {
    image = "sourcegraph/server:5.1.1";

    ports = [
      "127.0.0.1:3463:7080"
    ];

    volumes = [
      "/var/lib/sourcegraph/etc:/etc/sourcegraph"
      "/var/lib/sourcegraph/data:/var/opt/sourcegraph"
    ];

    # Sourcegraph needs a higher nofile limit, it logs warnings
    # otherwise (unclear whether it actually affects the service).
    extraOptions = [
      "--ulimit"
      "nofile=10000:10000"
    ];
  };
}

