{ pkgs, ... }:

{
  services.minecraft-server = {
    package = pkgs.minecraft-server;
    serverProperties = {
      server-port = 43000;
      difficulty = 3;
      gamemode = 1;
      max-players = 5;
      motd = "Neurodivergenter Hexenzirkel";
      white-list = false;
      enable-rcon = true;
      "rcon.password" = "hunter2";
    };
    openFirewall = true;
    jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
    eula = true;
    enable = true;
    declarative = true;
    dataDir = "/var/lib/minecraft";
  };
}
