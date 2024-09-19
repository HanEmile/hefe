# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
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
  ];

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
    };
  };

  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
  };
}
