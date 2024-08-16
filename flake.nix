{
  inputs = {
    nixpkgs.url = "git+https://github.com/nixos/nixpkgs?ref=release-24.05";
    nixpkgs-unstable.url = "git+https://github.com/nixos/nixpkgs?ref=nixpkgs-unstable";

    darwin.url = "git+https://github.com/lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "git+https://github.com/serokell/deploy-rs?ref=master";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "git+https://github.com/ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "git+https://github.com/nix-community/home-manager?ref=release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    naersk.url = "git+https://github.com/nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";

    # hefe-internal.url = "git+ssh://gitea@git.emile.space/hanemile/hefe-internal.git?ref=main";

    # nix registry add flake:mylocalrepo git+file:///path/to/local/repo
    # nix registry list
    # hefe-internal.url = "flake:mylocalrepo";
    # hefe-internal.url = "git+file:///Users/emile/Documents/hefe-internal";
    hefe-internal.url = "git+ssh://git@git.emile.space/hefe-internal";
  };

  outputs = {
    self,
    nixpkgs, nixpkgs-unstable, # general packages
    darwin, # darwin related stuff
    deploy-rs, # deploy the hosts
    agenix, # store secrets crypted using age
    home-manager, # manage my home envs
    naersk, # build rust stuff
    hefe-internal, # internal tooling
    ... }@inputs:
  let
    lib = import ./nix/lib inputs;
    helper = lib.flake-helper;
  in {

    hosts = {
      caladan = {
        system = "aarch64-darwin";
        sshUser = "hydra";
        homeManagerEnable = true;
        description = "macbook air";
        # nix run https://github.com/LnL7/nix-darwin/archive/master.tar.gz -- switch --flake .#caladan
      };
      corrino = {
        system = "x86_64-linux";
        ip = "corrino";
        description = "Hetzner AX41 dual 512GB NVME";
        modules = [ hefe-internal.nixosModules.corrino ];
      };
      chusuk = {
        # ip = "chusuk.pinto-pike.ts.net";
        system = "x86_64-linux";
        description = "lenovo t480";
      };
      hacknix = {
        # ip = "hacknix.pinto-pike.ts.net"; # clone repo and deploy within
        system = "x86_64-linux";
        description = "hacking vm";
      };
      mail = {
        # ip = "mail.pinto-pike.ts.net"; # clone repo and deploy within
        system = "x86_64-linux";
        description = "mail server";
      };

      #kolhar = {}; # nixos vm on caladan
      #hagal = {}; # apple tv
      
      lampadas = {
        system = "x86_64-linux"; # 4c4t (intel n100), 32GB RAM
        description = "NAS";
      };
      # palma = {
      #   description = "palma bmc";
      # };

      lernaeus = {
        system = "x86_64-linux"; # 8c16t (AMD ryzen 5 5600g), 32GB RAM 
        description = "VM Host";
      };
      # parmentier = {
      #   description = "lernaeus bmc";
      # };

      # lankiveil = {
      #   system = "x86_64-linux"; # ???, ???, RTX A2000
      #   description = "";
      # };
      # poritrin = {
      #   description = "lankiveil bmc";
      # };

      # kaitain = {};
      # ecaz = {};
      # gamont = {};

      # futher names: https://neoencyclopedia.fandom.com/wiki/List_of_Dune_planets
      # Muritan
      # Naraj
      # Palma
      # Parmentier
      # Poritrin
      # Richese
      # Romo
      # Rossak
      # Sikun
      # Synchrony
      # Tleilax
      # Tupile
      # Zanovar
    };

    nixosConfigurations = helper.mapToNixosConfigurations self.hosts;
    darwinConfigurations = helper.mapToDarwinConfigurations self.hosts;

    nixosModules = {
      emile = import ./nix/modules;
      default = self.nixosModules.emile;
    };

    overlays = {
      emile = import ./nix/pkgs/overlay.nix;
      default = self.overlays.emile;

      unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };

    deploy.nodes = helper.mapToDeployRsConfiguration self.hosts;
    deploy.autoRollback = true;

    packages =
      nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.emile

          # some arguments for packages
          (_: _: { inherit naersk; })
        ];
      };
    in {
      inherit (pkgs)
        vokobe
        r2wars-web
        # emu-riscv
        # emu-mips
        # emu-x86_64
        ;
    });

    hydraJobs = {
      inherit (self) packages;
      nixosConfigurations = helper.buildHosts self.nixosConfigurations;
    };

    templates = {
      # ; nix nix registry add hefe /Users/emile/Documents/hefe
      # ; nix flake init -t hefe#ctf
      ctf = {
        description = "A basic ctf env with pwn, rev, ... tools";
        path = ./nix/templates/ctf;
        welcomeText = ''
          # A basic CTF env
          ## Intended usage
          The intended usage of this flake is...

          ## More info
          - [Rust language](https://www.rust-lang.org/)
          - [Rust on the NixOS Wiki](https://nixos.wiki/wiki/Rust)
          - ...
        '';
      };
    };

    # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
