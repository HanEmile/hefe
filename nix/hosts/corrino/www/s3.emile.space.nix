{ config, ... }:

{
  services.nginx.virtualHosts."s3.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.emile.ports.minio.s3}";
      };
    };
  };

  services.nginx.virtualHosts."s3-web.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.emile.ports.minio.web}";
      };
    };
  };

  services.minio = {
    enable = true;
    region = "eu-north-1-hel-1a"; # corrino is in the helsinki hetzner dc

    listenAddress = "[::1]:${toString config.emile.ports.minio.s3}";

    browser = true;
    consoleAddress = "[::1]:${toString config.emile.ports.minio.web}";

    dataDir = [ "/minio/data" ];
    configDir = "/minio/config";

    rootCredentialsFile = config.age.secrets.minio_root_credz.path;
    # accessKey
  };
}
