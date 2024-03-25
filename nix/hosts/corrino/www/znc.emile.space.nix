{ config, pkgs, lib, ... }:

{
  services.nginx.virtualHosts."znc.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations."/".proxyPass = "http://127.0.0.1:5002";
  };

  services.znc = {
    enable = true;
    mutable = true;
    useLegacyConfig = false;

    openFirewall = false;

    modulePackages = with pkgs.zncModules; [
      clientbuffer
      clientaway
      playback
      privmsg
    ];

    config = lib.mkMerge [
      ({
        Version = lib.getVersion pkgs.znc;
        Listener = {
          l = { Port = 5002; SSL = false; AllowWeb = true;  };
          j = { Port = 5001; SSL = true;  AllowWeb = false; };
          LoadModule = [ "webadmin" "adminlog" "playback" "privmsg" ];
          User = {
            emile = {
              Admin = true;
              Nick = "hanemile";
              AltNick = "hanemile_";
              AutoClearChanBuffer = false;
              AutoClearQueryBuffer = false;
              LoadModule = [
                "clientbuffer autoadd"
                "buffextras"
                "clientaway"
              ];
              Network = {
                liberachat = {
                  Server = "irc.libera.char +6697";
                  Nick = "hanemile";
                  AltNick = "hanemile";
                  JoinDelay = 2;
                  LoadModule = [ "simple_away" "nickserv" "cert"];
                };
              };
            };
          };
        };
      })
    ];
    configFile = config.age.secrets.znc-config.path;
  };
}
