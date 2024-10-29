# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  ...
}:

let
  emile_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew emile@caladan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzLZ56SEgwZZ0OusTdSDDhpMlxSg1zPNdRLuxKOfrR5 emile@chusuk"
  ];
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  ##################
  # sound

  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;    ## If compatibility with 32-bit applications is desired.

  users.extraUsers.emile.extraGroups = [ "audio" ];

  ##################
  # nvidia foo

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ##################
  # xserver foo

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  services.displayManager.defaultSession = "none+i3";

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
      ];
    };
  };

  #########
  # sunshine foo

  services.sunshine = {
    enable = true;
    package = pkgs.sunshine;
    autoStart = true;

    # Whether to give the Sunshine binary CAP_SYS_ADMIN, required for DRM/KMS screen capture.
    capSysAdmin = true;

    # https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/advanced_usage.html#configuration
    # settings

    openFirewall = true;

    # applications.env
    # applications.apps
    # applications
  };

  ################
  # steam foo

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  
  ################
  # bluetooth

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  ################

  boot = {
    loader.systemd-boot.enable = true;
    kernelParams = [ "ip=dhcp" ];
    initrd = {
      availableKernelModules = [ "r8169" ];
      systemd.users.root.shell = "/bin/cryptsetup-askpass";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 22;
          hostKeys = [ "/initrd_ssh_host_key_ed25519" ];
        };
        postCommands = ''
          echo 'cryptsetup-askpass' > /root/.profile
        '';
      };
    };
  };

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  networking = {
    hostName = "lernaeus";
    firewall.enable = true;

    # iperf
    firewall.allowedTCPPorts = [ 5201 ];
    firewall.allowedUDPPorts = [ 5201 ];
  };

  time.timeZone = "Europe/Berlin";

  users.users = {
    root = {
      hashedPassword = "";
      openssh.authorizedKeys.keys = emile_keys;
    };
    emile = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = emile_keys;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    tailscale
    kitty
    firefox
    htop

    steam
    mangohud
    sunshine
    lutris

    protonup
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATH = "/home/emile/.steam/root/compatibilitytools.d";
  };

  programs.mosh.enable = true;

  services = {
    openssh.enable = true;
    vnstat.enable = true;
    tailscale.enable = true;

    btrfs = {
      autoScrub.enable = true;
      autoScrub.interval = "weekly";
    };

    prometheus.exporters = {
      node.enable = true;
      systemd.enable = true;
      smartctl.enable = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    extraOptions = ''
      extra-platforms = aarch64-linux, x86_64-linux, i686-linux
    '';
  };

  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
  };
}
