{ config, ... }:

{
  services.nginx.virtualHosts."photo.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.photoprism.port}";
        proxyWebsockets = true;
      };
    };
  };

  services.photoprism = {
    enable = true;

    address = "127.0.0.1";
    port = config.emile.ports.photo;

    passwordFile = config.age.secrets.photoprism_password.path;

    # originalsPath = "/data/photos";
    originalsPath = "/mnt/storagebox-bx11/photos";

    settings = {
      PHOTOPRISM_ADMIN_USER = "root";
      PHOTOPRISM_DEFAULT_LOCALE = "en";
      PHOTOPRISM_SITE_URL = "https://photo.emile.space";
    };
  };
}
