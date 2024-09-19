{ config, ... }:

{
  services = {
    nginx.virtualHosts = {
      "prometheus.emile.space" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}/";
          proxyWebsockets = true;
        };
      };
    };

    prometheus = {
      enable = true;
      retentionTime = "356d";

      listenAddress = "[::1]";
      port = config.emile.ports.prometheus.web;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = config.emile.ports.prometheus.exporter.node;
        };
        systemd = {
          enable = true;
          port = config.emile.ports.prometheus.exporter.systemd;
        };
        smartctl = {
          enable = true;
          port = config.emile.ports.prometheus.exporter.smartctl;
        };
        nginx = {
          enable = true;
          port = config.emile.ports.prometheus.exporter.nginx;
        };
      };
      scrapeConfigs = [
        {
          job_name = "corrino";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ]; }
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ]; }
          ];
        }
        {
          job_name = "lampadas";
          static_configs = [
            { targets = [ "lampadas:9100" ]; }
            { targets = [ "lampadas:9558" ]; }
            { targets = [ "lampadas:9633" ]; }
          ];
        }
      ];
    };
  };
}
