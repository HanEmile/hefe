{ config, pkgs, ... }:

{
  services.minecraft-server = {
    package = pkgs.minecraft-server;
    serverProperties = {
      server-port = 43000;

      # 0 peaceful
      # 1 easy
      # 2 normal
      # 3 hard
      difficulty = 1;

      # 0 survival
      # 1 creative
      # 2 adventure
      # 5 default
      # "spectator" spectator
      # gamemode = "survival";
      gamemode = 0;

      max-players = 10;
      motd = "Neurodivergenter Hexenzirkel";
      enable-rcon = true;
      "rcon.password" = "hunter2";
      enable-command-block = false;
      enable-query = false;
      spawn-protection = 0;

      white-list = true;
    };
    openFirewall = true;

    whitelist = {
      "emileemail" = "a7614a53-b8b8-47b7-91cf-860e7c7f325f";
      "dodonator23" = "f93506b6-76e8-437d-927d-dceeb833a33f";
      "ChaosAyumi" = "223040ec-ca30-4238-8b58-c81597c30426";
      "xerunala" = "962e41c8-1da8-4592-9a2f-e36cdb20d5a6";
      "rappet" = "588377a5-362f-4ea1-8195-9cf97dd7a884";
    };

    jvmOpts = "-Xms4092M -Xmx4092M";
    eula = true;
    enable = true;
    declarative = true;
    dataDir = "/var/lib/minecraft";
  };

  services.nginx.virtualHosts."mc.emile.space" = {
    forceSSL = true;
    enableACME = true;
  };

  services.bluemap = {
    enable = true;

    enableNginx = true;
    host = "mc.emile.space";

    webappSettings = {
      enabled = true;
      webroot = config.services.bluemap.webRoot;
    };

    # webserverSettings = {};
    webserverSettings.enabled = false; # using nginx;
    webRoot = "/var/lib/bluemap/web";

    # coreSettings = {};
    coreSettings.data = "/var/lib/bluemap";
    coreSettings.metrics = false; # don't send data to the devs

    storage = {
      "file" = {
        root = "${config.services.bluemap.webRoot}/maps";
      };
    };
    # storage.<name>.storage-type

    maps = let
      worldpath = "/var/lib/minecraft/world";
    in {
      "overworld" = {
        world = "${worldpath}";
        ambient-light = 0.1;
        cave-detection-ocean-floor = -5;
        dimension = "minecraft:overworld";
      };

      "nether" = {
        world = "${worldpath}/DIM-1";
        sorting = 100;
        sky-color = "#290000";
        void-color = "#150000";
        ambient-light = 0.6;
        world-sky-light = 0;
        remove-caves-below-y = -10000;
        cave-detection-ocean-floor = -5;
        cave-detection-uses-block-light = true;
        max-y = 90;
        dimension = "minecraft:the_nether";
      };

      "end" = {
        world = "${worldpath}/DIM1";
        sorting = 200;
        sky-color = "#080010";
        void-color = "#080010";
        ambient-light = 0.6;
        world-sky-light = 0;
        remove-caves-below-y = -10000;
        cave-detection-ocean-floor = -5;
        dimension = "minecraft:the_end";
      };
    };

    # A set of resourcepacks, datapacks, and mods to extract resources from, loaded in alphabetical order.
    packs = {};

    # How often to trigger rendering the map, in the format of a systemd timer onCalendar configuration. See systemd.timer(5).
    #
    # This one means "every three hours":
    # *-*-* */3:00:00
    onCalendar = "*-*-* *:00:00";

    eula = true;

    enableRender = true;

    # The world used by the default map ruleset. If you configure your own maps you do not need to set this.
    # defaultWorld = "${config.services.minecraft.dataDir}/world";
     
    addons = {};
  };

  services.restic.backups."minecraft" = {
    repository = "/mnt/storagebox-bx11/minecraft";
    paths = [ "/var/lib/minecraft" ];
    timerConfig = null;
    passwordFile = config.age.secrets.restic_password.path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
