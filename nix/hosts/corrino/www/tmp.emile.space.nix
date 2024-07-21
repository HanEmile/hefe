{
  services.nginx.virtualHosts."tmp.emile.space" = {
    forceSSL = true;
    enableACME = true;
    serverName = "tmp.emile.space";

    locations = {
      "/" = {
        root = "/var/www/tmp.emile.space";
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
          autoindex on;
        ''; 
      };
    };
  };
}
