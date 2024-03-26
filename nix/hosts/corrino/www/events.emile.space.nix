{ ... }:

let
  ports = import ../ports.nix;
in {
  services.nginx.virtualHosts."events.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        extraConfig = ''
          proxyPass = "http://[::1]:${toString ports.events}";
        '';
      };
    };
  };

  # Create users:
  #
  # go into the mobilizon-launchers directory within the nix store (systemctl
  # status mobilizon..., you'll find it there somehow)
  #
  # ; sudo -u mobilizon ./bin/mobilizon_ctl users.new emile@emile.space --moderator --admin

  services = {
    mobilizon = {
      enable = true;
      settings.":mobilizon" = {
        "Mobilizon.Web.Endpoint" = {
          url.host = "events.emile.space";
          http.port = ports.events;

          # The IP address to listen on. Defaults to [::1] notated as a byte
          # tuple.
          # (Yes, this is an elexir application and they've mapped the type system
          # into nix)
          http.ip = {
            _elixirType = "tuple";
            value = [ 0 0 0 0 0 0 0 1 ];
          };

          has_reverse_proxy = true;
        };

        "Mobilizon.Storage.Repo" = {
          username = "mobilizon";
          socket_dir = "/var/run/postgresql";
          database = "mobilizon_prod";
        };

        ":instance" = rec {
          name = "events.emile.space";
          hostname = "emile.space";
          email_reply_to = email_from;
          email_from = "noreply@$emile.space";
        };
      };
    };
  };
}
