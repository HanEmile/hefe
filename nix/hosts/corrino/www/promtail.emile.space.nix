{ config, ... }:

{
  # allow the promtail user to read the nginx access files
  users.users.promtail.extraGroups = [ "nginx" ];

  services = {
    promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = config.emile.ports.promtail;
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
              {
                timestamp = {
                  source = "time_local";
                  format = "02/Jan/2006:15:04:05 -0700";
                };
              }
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
