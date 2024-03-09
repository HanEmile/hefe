{ config, ... }:

# Future People: This place is not a place of honor... no highly esteemed deed
# is commemorated here... nothing valued is here...
# Look at the docker volumes section: You'll have to build and fail a few
# times... sorry

{
  services.nginx.virtualHosts."tickets.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        extraConfig = ''
          proxy_pass http://127.0.0.1:8349;

          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $host;
        '';
      };
    };
  };

  environment.etc."pretix.cfg".text = ''
    [pretix]
    instance_name=tickets.emile.space
    url=https://tickets.emile.space
    currency=EUR
    ; DO NOT change the following value, it has to be set to the location of the
    ; directory *inside* the docker container
    datadir=/data
    cookie_domain=tickets.emile.space
    trust_x_forwarded_for=on
    trust_x_forwarded_proto=on

    [database]
    backend=sqlite3

    [mail]
    ; See config file documentation for more options
    from=tickets@emile.space
    ; This is the default IP address of your docker host in docker's virtual
    ; network. Make sure postfix listens on this address.
    host=mail.emile.space
    user=mail

    ; something like this or so...
    ;password=${builtins.readFile config.age.secrets.mailserver_credz.path}
    ;password=this_is_an_example_password_changeme

    port=1025
    tls=on
    ssl=off

    [redis]
    location=unix:///pretix/redis.sock?db=0
    ; Remove the following line if you are unsure about your redis' security
    ; to reduce impact if redis gets compromised.
    sessions=true

    [celery]
    backend=redis+socket:///pretix/redis.sock?virtual_host=1
    broker=redis+socket:///pretix/redis.sock?virtual_host=2
  '';

  virtualisation.oci-containers.containers = {
    pretix = {
      image = "pretix/standalone:stable";
      ports = [
        "127.0.0.1:8349:80"
      ];
      volumes = [
        "/var/pretix-data:/data"
        "/etc/pretix:/etc/pretix"
        "/run/redis-pretix/redis.sock:/pretix/redis.sock"

        # update the below manually using the result from
        # ; readlink /etc/static/pretix.cfg
        # after building and failing once
        # (yes, I'm so annoyed that I can't mount symlinks into docker containers)
        # "/nix/store/vch1g88b5za1ab79cikil3n7wqrl8wxg-etc-pretix.cfg:/etc/pretix/pretix.cfg"
        "/nix/store/rcxvnbg7iqb1z011ybanj3982153xi70-etc-pretix.cfg:/etc/pretix/pretix.cfg"
      ];
    };
  };


  services.redis.vmOverCommit = true;
  services.redis.servers."pretix" = {
    enable = true;
    port = 0;
    unixSocketPerm = 666;
    user = "pretixuser";
  };

  users = {
    groups."pretixuser" = {};
    users."pretixuser" = {
      isNormalUser = true; # we're setting the uid manually, nix should detect
                           # this, but whatever...
      uid = 15371;
      group = "pretixuser";
      description = "The user for pretix. Created, as we need a user to set the permissions for the redis unix socket";
    };
  };
}
