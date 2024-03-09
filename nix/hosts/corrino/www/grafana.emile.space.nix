{ config, ... }:

{
  services = {
    nginx.virtualHosts."grafana.emile.space" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
          proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}/";
          proxyWebsockets = true;
      };
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3002;
          domain = "grafana.emile.space";
          root_url = "https://grafana.emile.space/";
        };
      };

      provision = {
        datasources = {
          settings = {
            datasources = [
              {
                url = "http://localhost:${toString config.services.prometheus.port}";
                type = "prometheus";
                name = "Prometheus";
                editable = false;
                access = "proxy"; # server = "proxy", browser = "direct"
              }
              {
                name = "loki";
                url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}";
                type = "loki";
              }
            ];
          };
        };
      };
    };

    prometheus = {
      enable = true;
      retentionTime = "356d";
      port = 9003;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
      scrapeConfigs = [
        {
          job_name = "corrino";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };

    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_port = 9004;
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "7d";
          max_global_streams_per_user = 100000;
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

        schema_config.configs = [{
          from = "2023-05-09";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
    };
  };

  # allow the promtail user to read the nginx access files
  users.users.promtail.extraGroups = [ "nginx" ];

  services = {
    promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 9005;
          grpc_listen_port = 0;
        };
        positions.filename = "/tmp/positions.yml";
        clients = [{
          url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }];
        scrape_configs = [

          # systemd
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }

          # nginx error log
          {
            job_name = "nginx-error-logs";
            static_configs = [{
              targets = [ "localhost" ];
              labels = {
                job = "nginx-error-logs";
                host = "corrino";
                __path__ = "/var/log/nginx/*error.log";
              };
            }];
          }

          # nginx
          {
            job_name = "nginx";
            static_configs = [
              {
                targets = [ "localhost" ];
                labels = {
                  job = "nginx";
                  host = "corrino";
                  __path__ = "/var/log/nginx/*access.log";
                };   
              }
            ];
            pipeline_stages = [
              # {
              #   regex = {
              #     expression = "(?:[0-9]{1,3}\.){3}([0-9]{1,3})";
              #     replace = "***";
              #   };
              # }
              {
                regex = {
                  expression = ''(?P<remote_addr>.+) - - \[(?P<time_local>.+)\] "(?P<method>.+) (?P<url>.+) (HTTP\/(?P<version>\d.\d))" (?P<status>\d{3}) (?P<body_bytes_sent>\d+) (["](?P<http_referer>(\-)|(.+))["]) (["](?P<http_user_agent>.+)["])'';
                };
              }
              {
                labels = {
                  remote_addr = null;
                  time_local = null;
                  method = null;
                  url = null;
                  status = null;
                  body_bytes_sent = null;
                  http_referer = null;
                  http_user_agent = null;
                };
              }
              # {
              #   timestamp = {
              #     source = "time_local";
              #     format = "02/Jan/2006:15:04:05 -0700";
              #   };
              # }
              {
                drop = {
                  source = "url";
                  expression = ''/(_matrix|.well-known|notifications|api|identity).*'';
                };
              }
              {
                drop = {
                  source = "url";
                  expression = ''grafana.*'';
                };
              }
            ];
          }

        ];
      };
    };
  };
}