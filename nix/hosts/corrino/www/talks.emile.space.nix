{ config, pkgs, ... }:

{
  services = {
    # so the default pretalx module doesn't allow TLS foo by default, don't ask
    # me why...
    nginx.virtualHosts."talks.emile.space" = {
      forceSSL = true;
      enableACME = true;
    };
    pretalx = {
      package = pkgs.pretalx;
      enable = true;
      plugins = with config.services.pretalx.package.plugins; [ pages ];
      user = "pretalx";
      group = "pretalx";
      nginx = {
        enable = true;
        domain = "talks.emile.space";
      };
      settings = {
        site = {
          url = "https://talks.emile.space";
          debug = false;
          csp = "https://talks.emile.space,http://localhost:8080,'self'";
        };
        mail = {
          from = "tickets@emile.space";
          host = "mail.emile.space";
          user = "mail";
          password = "${config.age.secrets.mail_password.path}";
          port = 1025;
          tls = "on";
          ssl = "off";
        };
        redis = {
          session = true;
          location = "unix://${config.services.redis.servers.pretalx.unixSocket}?db=0";
        };
      };
    };
  };
}
