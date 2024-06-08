# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

let 
  emile_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew emile@caladan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzLZ56SEgwZZ0OusTdSDDhpMlxSg1zPNdRLuxKOfrR5 emile@chusuk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMoHWyC9r0LVk6UlkhBWAJph0F6KHYHh83EI5U9wtfq2 shortcuts@ginaz"
  ];
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "ip=dhcp" ];
    initrd = {
      availableKernelModules = [ "r8169" ];
      systemd.users.root.shell = "/bin/cryptsetup-askpass";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 22;
          hostKeys = ["/initrd_ssh_host_key_ed25519"];
          authorizedKeys = emile_keys;
        };
        postCommands = ''
          echo 'cryptsetup-askpass' > /root/.profile
        '';
      };
      luks.devices = {
      	# unsure why luksdata1 is recognized and added to the
      	# hardware-configuration.nix automatically, but luksdata2 isn't 
        "luksdata2".device = "/dev/disk/by-uuid/e94d7f32-26ef-41e1-b3f3-9e63e4858001";
      };
    };
  };

  fileSystems = {
    "/".options = ["compress=zstd"];
    "/home".options = ["compress=zstd"];
    "/nix".options = ["compress=zstd" "noatime"];
  };

  networking = {
    hostName = "lampadas";
    firewall.enable = true;
  };

  time.timeZone = "Europe/Berlin";

  powerManagement = {
    powertop.enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "";
        openssh.authorizedKeys.keys = emile_keys;
      };
      emile = {
        isNormalUser = true;
        extraGroups = [ "wheel" "samba-guest" ];
        openssh.authorizedKeys.keys = emile_keys;
      };
      samba-guest = {
        isSystemUser = true;
        description = "Samba guest user";
        group = "samba-guest";
        home = "/var/empty";
        createHome = false;
        shell = pkgs.shadow;
      };
    };
  };
  users.groups.samba-guest = {};

  systemd.tmpfiles.rules = [
    "d /data 0755 root root"
    "d /data/private 0755 emile users"
    "d /data/public 0755 samba-guest samba-guest"
    "d /data/time_machine 0755 emile users"
  ];

  environment.systemPackages = with pkgs; [ vim tailscale ];

  programs.mosh.enable = true;

  services = {
    # traffic metrics
    vnstat.enable = true;

    # ssh access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # VPN
    tailscale.enable = true;

    # filesystem stuff
    btrfs = {
      autoScrub.enable = true;
      autoScrub.interval = "weekly";
    };

    # metric exporters
    prometheus.exporters = {
      node.enable = true;
      systemd.enable = true;
      smartctl.enable = true;
    };

    # shares
    samba = {
      enable = true;
      openFirewall = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = lampadas
        netbios name = lampadas
        security = user 
        hosts allow = 100.64.0.0/255.192.0.0, 127.0.0.1/255.0.0.0, ::1, 192.168.0., 192.168.1.
        hosts deny = 0.0.0.0/0
        guest account = samba-guest 
        map to guest = bad user
        load printers = no
        server min protocol = SMB3
        server smb encrypt = required 
        read raw = Yes
        write raw = Yes
        socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
        min receivefile size = 16384
        use sendfile = true
        aio read size = 16384
        aio write size = 16384
        server multi channel support = yes
      '';
      shares = {
        public = {
          path = "/data/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "guest only" = "yes";
          "available" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "comment" = "public data";
          "writable" = "yes";
        };
        private = {
          path = "/data/private";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "emile";
          "comment" = "private data (no flags though)";
        };
        time_machine = {
          path = "/data/time_machine";
          "public" = "no";
          "writeable" = "yes";
          "valid users" = "emile";
          "force user" = "emile"; 
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "fruit:delete_empty_adfiles" = "yes";
          "fruit:veto_appledouble" = "no";
          "fruit:wipe_intentionally_left_blank_rfork" = "yes";
          "fruit:posix_rename" = "yes";
          "fruit:metadata" = "stream";

          # otherwise, copying on the server happens Server -> Client ->
          # Server (but only on macos)
          "fruit:copyfile" = "yes";

          "vfs objects" = "catia fruit streams_xattr";
          "comment" = "time machine backups";
        };
      };
    };
  };

  system = {
    stateVersion = "23.11";
    autoUpgrade.enable = true;
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
}

