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

  # macos sonoma claimed 300, 301, 302, 303 and 304

  # users.groups."nixbld".name = "nixbld";
  # users.users."_nixbld1" = {
  #   name = "_nixbld1";
  # };

  # users.users."_nixbld1".uid = 305;
  # users.users."_nixbld2".uid = 306;
  # users.users."_nixbld3".uid = 307;
  # users.users."_nixbld4".uid = 308;
  # users.users."_nixbld5".uid = 309;

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
      trusted-users = [ "root" "hydra" "emile" ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];

      experimental-features = [ "nix-command" "flakes" ];
    };

    distributedBuilds = true;

  	buildMachines = [
      {
        hostName = "corrino.emile.space";
        system = "x86_64-linux";
        maxJobs = 16;
        speedFactor = 2;

        # Feature	      | Derivations requiring it
        # ----------------|-----------------------------------------------------
        # kvm	            | Everything which builds inside a vm, like NixOS tests
        # nixos-test	    | Machine can run NixOS tests
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
