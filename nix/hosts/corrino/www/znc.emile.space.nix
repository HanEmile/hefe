{ ... }:

{
  services.nginx.virtualHosts."znc.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:5000";
      };
    };
  };

  services.znc = {
    enable = true;
    openFirewall = true;
    useLegacyConfig = false;

    config = {
      LoadModule = [ ];
      User.Emile = {
        Admin = true;
        Nick = "hanemile";
        RealName = "Emile";
        # QuitMsg = "iowait()";
        LoadModule = [ "chansaver" "controlpanel" ];

        Network.libera = {
          Server = "irc.libera.chat +6697";
          LoadModule = [ "simple_away" ];
          Chan = {
            "#nixos" = { Detached = false; };
            "##linux" = { Disabled = true; };
          };
        };

        Pass.password = { # hunter2
          Method = "sha256";
          Hash =
            "31357a874d929871b7c2267721501aaa1f3c570ddc72eb6fb6d065fe72dbc2e4";
          Salt = "Oo1du8jahquataexai6Eiph9OcohpoL3";
        };
      };
    };
  };
}
