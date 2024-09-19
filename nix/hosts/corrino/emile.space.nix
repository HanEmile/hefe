{
  services.nginx.virtualHosts."emile.space" = {
    forceSSL = true;
    enableACME = true;

    # kTLS = true;

    locations = {
      "/" = {
        root = "/var/www/emile.space";
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        '';
      };

      #"/.well-known" = {
      #  root = "/var/www/emile.space";
      #  extraConfig = ''
      #    autoindex on;
      #  '';
      #};

      ## I ran a matrix homeserver for some time, then stopped, but the other
      ## homeserver don't know and don't stop sending me requests (5e5 a day or
      ## so).
      #"/.well-known/matrix/server".extraConfig = ''
      #  return 410;
      #'';
    };
  };

  # services.stargazer = {
  #   enable = true;
  #   user = "stargazer";
  #   group = "stargazer";

  #   certLifetime = "1m";
  #   store = /var/lib/gemini/certs;

  #   genCerts = true;
  #   regenCerts = true;
  #   responseTimeout = 0;
  #   requestTimeout = 5;

  #   routes = [
  #     {
  #       route = "emile.space";
  #       root = "/srv/gemini/emile.space";
  #     }
  #   ];

  #   listen = [ "0.0.0.0" "[2002:a00:1::]" ];

  #   ipLogPartial = false;
  #   ipLog = false;
  #   connectionLogging = false;

  #   certOrg = "emile.space";
  # };
}
