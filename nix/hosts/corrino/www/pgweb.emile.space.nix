{ pkgs, ... }:

let
  ports = import ../ports.nix;
in {
  services.nginx.virtualHosts."pgweb.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString ports.pgweb}";
      };
    };
  };

  environment.systemPackages = with pkgs; [ pgweb ];

  # systemd.services.pgweb = {
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.ExecStart = "${pkgs.pgweb}/bin/pwgeb";
  # };
}
