{ config, pkgs, ... }:

# TODO(emile): use the 24.05 nix module

let
  ports = import ../ports.nix;
  pretalx_config = pkgs.writeText "/etc/pretalx.cfg" ''
    [filesystem]
    media = /public/media
    data = /public/data
    static = /pretalx/src/static.dist

    [site]
    ; never run debug in production
    debug = False
    url = https://talks.emile.space
    csp=https://talks.emile.space,http://localhost:8080,'self'

    [database]
    backend=sqlite3

    [mail]
    from = pretalx@emile.space
    host = mail.emile.space
    port = 1025
    user = mail
    password=${config.age.secrets.mail_password.path}
    tls = True
    ssl = False

    [celery]
    backend=redis+socket:///pretalx/redis.sock?virtual_host=1
    broker=redis+socket:///pretalx/redis.sock?virtual_host=2

    [redis]
    location=unix:///pretalx/redis.sock?db=0
    ; Remove the following line if you are unsure about your redis' security
    ; to reduce impact if redis gets compromised.
    sessions=true    
  ''; 
in {
  services.nginx.virtualHosts."talks.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        extraConfig = ''
          proxy_pass http://127.0.0.1:${toString ports.talks};

          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $host;
        '';
      };
      "/media/" = {
        root = "/var/pretalx-public/";
      };
      "/static/" = {
        root = "/var/pretalx-public/";
      };
    };
  };

  virtualisation.oci-containers.containers = {
    pretalx = {
      image = "pretalx/standalone:latest";
      ports = [
        "127.0.0.1:${toString ports.talks}:80"
      ];
      volumes = [
        "/var/pretalx-data:/data" # {static, media}
        "/var/pretalx-public:/public"
        "/var/pretalx-public/static:/pretalx/src/static.dist"

        # "/var/pretalx-public-media:/public/media"
        "${pretalx_config}:/etc/pretalx/pretalx.cfg:ro"
        "/run/redis-pretalx/redis.sock:/pretalx/redis.sock"
      ];
    };
  };

  services.redis.vmOverCommit = true;
  services.redis.servers."pretalx" = {
    enable = true;
    port = 0;
    unixSocketPerm = 666;
    user = "pretalxuser";
  };

  users = {
    groups."pretalxuser" = {};
    users."pretalxuser" = {
      #isNormalUser = true; # we're setting the uid manually, nix should detect this, but whatever...
      uid = 999;
      group = "pretalxuser";
      description = "The user for pretalx. Created, as we need a user to set the permissions for the redis unix socket";
    };
  };

  # 15,45 * * * * docker exec pretalx-app pretalx runperiodic
}
