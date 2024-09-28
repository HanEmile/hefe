{ config, ... }:

{
  services = {
    loki = {
      enable = false;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_port = config.emile.ports.loki;
        };

        limits_config = {
          reject_old_samples = false;
          reject_old_samples_max_age = "7d";
          max_global_streams_per_user = 100000;
          max_streams_per_user = 100000;

          retention_period = "10m";
        };

        compactor = {
          retention_enabled = true;
          delete_request_store = "tsdb";
        };

        common = {
          instance_addr = "127.0.0.1";
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        # limits_config.allow_structured_metadata = false;

        schema_config.configs = [
          {
            from = "2023-05-09";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
          {
            from = "2024-10-18";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
    };
  };
}
