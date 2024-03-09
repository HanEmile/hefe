{ ... }:

{
  services.agate = {
    # TODO: fix link generation in vokobe
    enable = true;
    contentDir = "/var/www/emile.space";
    hostnames = [
      "emile.space"
    ];
    addresses = [
      "0.0.0.0:1965"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 1965 ];
}
