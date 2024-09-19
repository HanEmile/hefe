{ config, ... }:

{
  # Create a tls cert for the irc server
  security.acme.certs = {
    "irc.emile.space" = {
      webroot = "/var/lib/acme/acme-challenge/";
      email = "acme@emile.space";
      postRun = "cp fullchain.pem /home/ergo/ && cp key.pem /home/ergo && chown ergo:ergo /home/ergo/*.pem && systemctl reload ergo.service";
    };
  };

  # Allow ergo to access the created cert
  # The systemd server runs using a dynamic user, so the below inserts the .pem files
  #   into "/run/credentials/ergochat.service/key.pem"
  systemd.services.ergochat.serviceConfig = {
    LoadCredential = [
      "fullchain.pem:/var/lib/acme/irc.emile.space/fullchain.pem"
      "key.pem:/var/lib/acme/irc.emile.space/key.pem"
    ];
  };

  # allow connections to the port from the "outside"
  networking.firewall.allowedTCPPorts = [ config.emile.ports.irc.ssl ];

  services.ergochat = {
    enable = true;

    # https://raw.githubusercontent.com/ergochat/ergo/master/default.yaml
    settings = {
      accounts = {
        authentication-enabled = true;
        multiclient = {
          allowed-by-default = true;
          always-on = "opt-out";
          auto-away = "opt-out";
          enabled = true;
        };
        registration = {
          enabled = true;
          allow-before-connect = true;
          bcrypt-cost = 4;
          email-verification = {
            enabled = false;
          };
          throttling = {
            duration = "10m";
            enabled = true;
            max-attempts = 30;
          };
        };
      };
      channels = {
        default-modes = "+ntC";
        registration = {
          enabled = true;
        };
      };
      datastore = {
        autoupgrade = true;
        path = "/var/lib/ergo/ircd.db";
      };
      history = {
        enabled = true;
        autoreplay-on-join = 0;
        autoresize-window = "3d";
        channel-length = 2048;
        chathistory-maxmessages = 100;
        client-length = 256;
        restrictions = {
          expire-time = "1w";
          grace-period = "1h";
          query-cutoff = "none";
        };
        retention = {
          allow-individual-delete = false;
          enable-account-indexing = false;
        };
        tagmsg-storage = {
          default = false;
          whitelist = [
            "+draft/react"
            "+react"
          ];
        };
        znc-maxmessages = 2048;
      };
      limits = {
        awaylen = 390;
        channellen = 64;
        identlen = 20;
        kicklen = 390;
        nicklen = 32;
        topiclen = 390;
      };
      network = {
        name = "emilespace";
      };
      server = {
        casemapping = "permissive";
        check-ident = false;
        enforce-utf = true;
        forward-confirm-hostnames = false;
        ip-cloaking = {
          enabled = false;
        };
        ip-limits = {
          count = false;
          throttle = false;
        };
        listeners = {
          # sts only port
          ":6667".sts-only = true;

          # loopback listeners
          # "127.0.0.1:6668" = {};
          # "[::]:6668" = {};

          ":${toString config.emile.ports.irc.ssl}" = {
            tls = {
              cert = "/run/credentials/ergochat.service/fullchain.pem";
              key = "/run/credentials/ergochat.service/key.pem";
            };

            # for cloud load balancers setting a PROXY header, NOT reverse proxies...
            proxy = false;

            min-tls-version = 1.2;
          };
        };
        lookup-hostnames = false;
        max-sendq = "1M";
        name = "emile.space";
        relaymsg = {
          enabled = false;
        };
        sts = {
          enabled = true; # redirect from plain to tls if supported

          # how long clients should be forced to use TLS for.
          # (Emile): no clue why, can I set something like \infty here?
          duration = "12m";

        };
      };
      logging = [
        {
          method = "stderr";
          type = "* -userinput -useroutput";
          level = "debug";
        }
      ];
    };
  };
}
