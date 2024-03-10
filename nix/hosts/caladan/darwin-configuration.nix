{ pkgs, lib, ... }:

{
  imports = [
    ./overlay.nix
  ];

  users.users.emile = {
    name = "emile";
    home = "/Users/emile";
  };

  users.users.hydra = {
    name = "hydra";
    home = "/Users/hydra";
  };

  nix = {
    useDaemon = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
  		builders-use-substitutes = true
      auto-optimise-store = true
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';

    settings = {
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
        "https://cache.nixos.org"
      ];

      experimental-features = [ "nix-command" "flakes" ];
    };

    distributedBuilds = true;

  	buildMachines = [
      {
        hostName = "corrino.emile.space";
        system = "x86_64-linux";
        maxJobs = 8;
        speedFactor = 2;

        # Feature	      | Derivations requiring it
        # ----------------|-----------------------------------------------------
        # kvm	          | Everything which builds inside a vm, like NixOS tests
        # nixos-test	  | Machine can run NixOS tests
        # big-parallel    | kernel config, libreoffice, evolution, llvm and chromium.
        # benchmark	      | Machine can generate metrics (Means the builds usually
        #                 | takes the same amount of time)

        # cat /etc/nix/machines
        # root@corrino  x86_64-linux      /home/nix/.ssh/id_ed25519        8 1     kvm,benchmark

        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
    	}
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  programs.fish.enable = true;

  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    systemPackages = [
      pkgs.yarr
    ];
    shells = with pkgs; [ bashInteractive zsh fish ];
  };

}
