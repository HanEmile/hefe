# Edit ths configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ nixpkgs, nixpkgs-unstable, config, lib, pkgs, ... }:

let
  burppro = pkgs.callPackage ./burpsuitepro { inherit pkgs; nixpkgs=pkgs; };
  # TODO: pull licence from git
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./overlay
    ];

  nixpkgs = {
    config.allowUnfree = true; # for virtualisation.virtualbox
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hacknix";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  # fileSystems."/home/hack/Documents/datapool.lan" = {
  #   device = "datapool.lan:/mnt/data/dump";
  #   fsType = "nfs";
  # };

  services = {
    dbus.enable = true;
    xserver = {
    enable = true;

     # Keyboard settings
     layout = "us";
     xkbOptions = "caps:compose";

     desktopManager = {
       xterm.enable = false;

       # we don't use the xfce interface, only the fancy desktopManager
       # settings and the session
       xfce = {
         enable = true;
         noDesktop = true;
         enableXfwm = false;
       };
     };

     # default display manager when logging in
     displayManager = {
       defaultSession = "xfce+i3";
       sessionCommands = ''
       '';
     };

     windowManager.i3 = {
       enable = true;
       configFile = "/etc/i3.conf"; # see environment.etc."i3.conf".text
       extraPackages = with pkgs; [
         dmenu
         i3status i3blocks
       ];
     };
    };
  };

  environment.etc."i3.conf".text = pkgs.callPackage ./i3-config.nix {};

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  hardware.opengl.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.hack = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "vboxsf" # Allow access to the shared /pentest folder mounted in via virtualbox
      "docker" # access to the docker socket
    ];
    shell = pkgs.zsh;
  };

  environment = {
    shellAliases = {
      #ls = "lsd";
      ls = "eza";
    };
    systemPackages = with pkgs; [
      unstable.obsidian

      kitty 

      # editors
      vim

      helix
        marksman # markdown lsp
        cuelsp # cue lsp
        terraform-lsp terraform-ls # terraform lsp
        # rnix-lsp # nix lsp (CVE-2024-27297, that's why it's commented!)

      # command line tools
      fd
      ripgrep
      htop
      fzf
      jq
      eza
      lsd
      du-dust
      pwgen

      # x11 foo
      arandr
      feh

      # shell
      zsh oh-my-zsh

      # browser
      chromium
      firefox

      # programming languages
      go
      gopls # (Official language server for the Go language)
      go-outline # (Utility to extract JSON representation of declarations from a Go source file)
      go-tools # staticcheck (A collection of tools and libraries for working with Go code, including linters and static analysis)
      gocode-gomod # (An autocompletion daemon for the Go programming language)
      gotest # (go test with colors)
      gotests # (Generate Go tests from your source code)
      gomodifytags # (Go tool to modify struct field tags)
      impl # (Generate method stubs for implementing an interface)
      delve # dlv (debugger for the Go programming language)

      (pkgs.python3.withPackages (ps: with ps; [
        pwntools
        requests 
        tqdm 
        beautifulsoup4
        mitmproxy

        (
          buildPythonPackage rec {
            pname = "pandoc";
            version = "2.3";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-53LCxthxFGiUV5go268e/VOOtk/H5x1KazoRoYuu+Q0=";
            };
            doCheck = false;
            propagatedBuildInputs = [
              # pkgs.python310Packages.ply
              # pkgs.python310Packages.plumbum
              # Specify dependencies
              #pkgs.python3Packages.numpy
            ];
          }
        )
      ]))

      # dev
      vscode
      docker-compose

      # analysis
      binwalk
      file

      # communication
      element-desktop

      # view pdfs
      zathura okular

      # infra 
      cue
      cuetools
      
      #radare2
      # r2
      capstone # Advanced disassembly library
      keystone # Lightweight multi-platform, multi-architecture assembler framework
      unicorn # Lightweight multi-platform CPU emulator library

      # hashicorp stuff
      # vault vault-bin vaultenv vault-medusa
      # nomad_1_4
      # consul
      # terraform

      #unstable.mitmproxy
      #mitmproxy_bs4

      dex
      xss-lock
      networkmanagerapplet

      p7zip
      m4

      libreoffice

      pandoc
      tmux

      python311Packages.python-lsp-server
    ] ++ [
      burppro
    ]; 
  };

  fonts.packages = with pkgs; [
    ubuntu_font_family # the font used in the "Sogeti" logo
    #nerdfonts
    #font-awesome
    #powerline-fonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
 
    vim.defaultEditor = true;

    htop = {
      enable = true;
      settings = {
        hide_kernel_threads = true; 
      };
    };

    #fish.enable = true;
    zsh = {
      enable = true;
      syntaxHighlighting = {
        enable = true;
      };
      ohMyZsh = {
        enable = true;
        plugins = [ "nmap" ];
      };

      # this par in ~/.zshrc:
      # 
      # PROMPT="; "
      # RPROMPT="%F{green}%/%F{reset}"
      # ZSH_THEME=
      # PATH=$PATH:/home/hack/.cargo/bin
    };

    chromium = {
      enable = true;
      homepageLocation = "https://emile.space";
      extraOpts = {
        "ClientCertificateManagementAllowed" = 0; 
      };
    };

    git = {
      enable = true;
      config = {
        core.editor = "vim";
        user = {
          name = "Emile Hansmaennel";
          email = "emile.hansmaennel@sogeti.com";
        };
      };
    };
  };

  # virtualbox guest additions
  virtualisation.virtualbox.guest.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "12:00"; # daily, docs on format in `man 7 systemd.time`
      persistent = true;
    };

    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nixbinarycache.lan:JDjlVLc+5VUKOtFAFBGCDtlgVpLEaaR2JdTw2mQUIb8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # the office root_ca
  security.pki.certificates = [
    # office.lan
    ''
      *.office.lan
      ============
      -----BEGIN CERTIFICATE-----
      MIIBezCCASGgAwIBAgIQdkxWKinry5WWfV2CTRRHfzAKBggqhkjOPQQDAjAcMRow
      GAYDVQQDExFPZmZpY2UgQ0EgUm9vdCBDQTAeFw0yMDEwMjYxMjQ2MTlaFw0zMDEw
      MjYxMjQ2MTlaMBwxGjAYBgNVBAMTEU9mZmljZSBDQSBSb290IENBMFkwEwYHKoZI
      zj0CAQYIKoZIzj0DAQcDQgAEZ/Ac4kmThYXE0ZUBWvTSvgi4fcR19dgL2hROxSfH
      2RLW7hQzArloxhOzs+28VttiVh13lB4rSCvHe3TGA44c5KNFMEMwDgYDVR0PAQH/
      BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHQYDVR0OBBYEFE0i80PVvdecDvDp
      MpO2VtGluzxcMAoGCCqGSM49BAMCA0gAMEUCIQDP9Z1J3Z++6atOdHNTqd0PZ/pi
      w7HjGPxpRneD4/3vTwIgSoE5Gb3umt+FxIvv9WDFlsWSVRJ5wE6KpCkdGWWzWuU=
      -----END CERTIFICATE-----
    ''
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking = {
    nameservers = [
      "192.168.1.1"
      #"8.8.8.8"
    ];

    hosts = {
      # 127.0.0.1 localhost
      # ::1 localhost
    };
    
    firewall = {
      enable = true;

      # open further TCP and/or UDP ports in the firewall
      allowedTCPPorts = [ 80 443 8123 8080 ];
      #allowedUDPPorts = [ 53 ];
    };

    wg-quick.interfaces = {
      "wg0" = {
        address = [
          "10.10.10.12/24" # our IP
        ];
        dns = [ "192.168.1.1" ];
        mtu = 1380;
        listenPort = 51820;

        # TODO: add private key to repo using agenix, then link here
        privateKeyFile = "/etc/wireguard/private_key";

        peers = [
          {
            publicKey = "9+4OWuqZ0rZsi/oaaXd3YhE1p+Z0tbxwfNbcDnVqRxg=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "PUBLIC_IP:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  virtualisation.docker.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

