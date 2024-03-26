{ config, ... }:

let
  ports = import ../ports.nix;
in {
  services.nginx.virtualHosts."hydra.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
      };
    };
  };

  # make hydra send emails
  services.postfix = {
    enable = true;
    setSendmail = true;
  };

  services.hydra = {
    enable = true;

    listenHost = "*";
    port = ports.hydra;
    hydraURL = "https://hydra.emile.space"; # externally visible URL

    # Directory that holds Hydra garbage collector roots.
    gcRootsDir = "/nix/var/nix/gcroots/hydra";


    # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/hosts
    buildMachinesFiles = [];
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;


    # notification settings
    smtpHost = "mail.emile.space";
    notificationSender = "hydra@emile.space";

    # Threshold of minimum disk space (GiB) to determine if the evaluator should run or not.
    minimumDiskFreeEvaluator = 20;

    # Threshold of minimum disk space (GiB) to determine if the queue runner should run or not.
    minimumDiskFree = 20;

    # Path to a file containing the logo of your Hydra instance
    # logo = ;

    extraConfig = ''
      <git-input>
        timeout = 3600
      </git-input>
    '';
  };
}
