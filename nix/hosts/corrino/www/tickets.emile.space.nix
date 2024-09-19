{ config, pkgs, ... }:

# initially login as `admin@localhost` with the passwords `admin`
# (yes, I've changed this, this is just a note for if I forget when reading
# this in the future)

{
  # so the default pretix module doesn't allow TLS foo by default, don't ask
  # me why...
  services.nginx.virtualHosts."tickets.emile.space" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "tickets.hackoween.de" ];
  };

  services = {
    pretix = {
      enable = true;
      package = pkgs.pretix;
      plugins = with config.services.pretix.package.plugins; [
        passbook
        pages
      ];
      user = "pretix";
      group = "pretix";
      gunicorn.extraArgs = [
        "--name=pretix"
        "--workers=4"
        "--max-requests=1200"
        "--max-requests-jitter=50"
        "--log-level=info"
      ];
      nginx = {
        enable = true;
        domain = "tickets.emile.space";
      };
      settings = {
        pretix = {
          instance_name = "tickets.emile.space";
          url = "https://tickets.emile.space";
          currency = "EUR";
          datadir = "/var/lib/pretix";
          cookie_domain = "tickets.emile.space";
          trust_x_forwarded_for = "on";
          trust_x_forwarded_proto = "on";
        };

        database = {
          backend = "sqlite3";
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
          location = "unix://${config.services.redis.servers.pretix.unixSocket}?db=0";
          sessions = true;
        };
      };
    };
  };
}
