{ config, pkgs, ... }:

{
  security.acme.certs."s3.emile.space" = {
    group = "nginx";
    domain = "s3.emile.space";
    extraDomainNames = [
      "*.s3.emile.space"
      "*.s3-web.emile.space"
    ];
  };

  services.nginx.virtualHosts."s3.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.emile.ports.garage.s3}";
      };
    };
  };

  services.nginx.virtualHosts."s3-web.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.emile.ports.garage.web}";
      };
    };
  };

  services.garage = {
    enable = true;
    package = pkgs.garage_1_x;
    settings = {
      data_dir = [
        { capacity = "50G"; path = "/var/lib/garage/data"; }
      ];

      db_engine = "sqlite";
      replication_factor = 3;

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:${toString config.emile.ports.garage.s3}";
        root_domain = "s3.emile.space";
      };
      s3_web = {
        bind_addr = "[::]:${toString config.emile.ports.garage.web}";
        root_domain = "s3-web.emile.space";
        index = "index.html";
      };
      admin = {
        api_bind_addr = "[::]:${toString config.emile.ports.garage.admin}";
        # metrics_token = config.age.secrets.garage_admin_metrics_secret.path;
        # admin_token = config.age.secrets.garage_admin_token_secret.path;
      };

      # rpc_secret_file = config.age.secrets.garage_rpc_secret.path;
      rpc_bind_addr = "[::]:${toString config.emile.ports.garage.rpc}";
      rpc_bind_outgoing = false;
      rpc_public_addr = "[fc00:1::1]:${toString config.emile.ports.garage.rpc}";
    };

    environmentFile = config.age.secrets.garage_env.path;
  };
#         metrics_token = config.age.secrets.garage_admin_metrics_secret.path;
#         admin_token = config.age.secrets.garage_admin_token_secret.path;
#       rpc_secret_file = config.age.secrets.garage_rpc_secret.path;

# nix/hosts/corrino/secrets/garage_admin_metrics_secret.age
# nix/hosts/corrino/secrets/garage_admin_token_secret.age  
# nix/hosts/corrino/secrets/garage_admin_token.age         
# nix/hosts/corrino/secrets/garage_metrics_token.age       
# nix/hosts/corrino/secrets/garage_rpc_secret.age
  
  # services.garage = {
  #   enable = true;
  #   package = pkgs.garage_1_x;
  #   settings = {
  #     db_engine = "sqlite";
  #     replication_factor = 2;

  #     data_dir = [
  #       { capacity = "50G"; path = dataDir; }
  #     ];

  #     compression_level = 1;

  #     rpc_secret_file = config.age.secrets.garage_rpc_secret.path;
  #     rpc_bind_addr = "[::]:${toString config.emile.ports.garage.rpc}";
  #     rpc_bind_outgoing = false;
  #     rpc_public_addr = "[fc00:1::1]:${toString config.emile.ports.garage.rpc}";

  #     allow_world_readable_secrets = false;

  #     s3_api = {
  #       api_bind_addr = "[::]:${toString config.emile.ports.garage.s3}";
  #       s3_region = "garage";
  #       root_domain = "s3.emile.space";
  #     };

  #     s3_web = {
  #       bind_addr = "[::]:${toString config.emile.ports.garage.web}";
  #       root_domain = "s3-web.emile.space";
  #       add_host_to_metrics = true;
  #     };

  #     admin = {
  #       api_bind_addr = "[::]:${toString config.emile.ports.garage.admin}";
  #       metrics_token = config.age.secrets.garage_admin_metrics_secret.path;
  #       admin_token = config.age.secrets.garage_admin_token_secret.path;
  #       trace_sink = "http://localhost:4317";
  #     };

  #   };
  #   logLevel = "trace"; # info
  # };
}
