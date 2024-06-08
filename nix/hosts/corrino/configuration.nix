{ config, pkgs, ... }:

let
  ports = import ./ports.nix;
  keys = {
    emile = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew emile@caladan"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMoHWyC9r0LVk6UlkhBWAJph0F6KHYHh83EI5U9wtfq2 shortcuts@ginaz"
    ];
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # web
      ./www/emile.space.nix
      # ./www/git.emile.space.nix
      ./www/cgit.emile.space.nix
      # ./www/cl.emile.space.nix
      ./www/hydra.emile.space.nix
      ./www/netbox.emile.space.nix
      # ./www/grafana.emile.space.nix
      ./www/photo.emile.space.nix
      # ./www/events.emile.space.nix
      ./www/tickets.emile.space.nix
      ./www/talks.emile.space.nix
      ./www/stream.emile.space.nix
      ./www/pgweb.emile.space.nix
      ./www/ctf.emile.space.nix
      ./www/md.emile.space.nix
      # ./www/magic-hash.emile.space.nix
      # ./www/znc.emile.space.nix

      # gemini
      ./gemini/emile.space.nix

      # general purpose modules
      ./modules/authelia.emile.space.nix

      # containers
    ];

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot = {
    #supportsInitrdSecrets = true;

    loader.systemd-boot.enable = false;
    loader.grub = {
      enable = true;
      efiSupport = false;
      enableCryptodisk = true;
      device = "nodev";
      devices = [ "/dev/nvme0n1" "/dev/nvme1n1"];
    };

    kernelParams = [ "ip=135.181.142.139::135.181.142.129:255.255.255.192:corrino:enp35s0:off:8.8.8.8:8.8.4.4:" ];

    initrd = {
      kernelModules = [ "dm-snapshot" ];

      availableKernelModules = [ "cryptd" "aesni_intel" "igb" ];#"FIXME Your network driver" ];

      network = {
        enable = true;
        ssh = {
          enable = true;
      
          # ssh port during boot for luks decryption
          port = ports.initrd_ssh;
          authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
          hostKeys = [ "/initrd_ssh_host_ecdsa_key" ];
        };
        postCommands = ''
          echo 'cryptsetup-askpass' >> /root/.profile
        '';
      };

      luks = {
        forceLuksSupportInInitrd = true;
        devices = {
          root = {
            preLVM = true;
            device = "/dev/md1";
            allowDiscards = true;
          };
        };
      };
                  
      secrets = {
        "/initrd_ssh_host_ecdsa_key" = "/initrd_ssh_host_ecdsa_key";
      };

      # The RAIDs are assembled in stage1, so we need to make the config
      # available there.
      # services.swraid.mdadmConf = config.environment.etc."mdadm.conf".text;
    };

    # From the nixos 23.11 release notes changelog breaking changes section:
    # mdraid support is optional now. This reduces initramfs size and prevents
    # the potentially undesired automatic detection and activation of software
    # RAID pools. It is disabled by default in new configurations (determined
    # by stateVersion), but the appropriate settings will be generated by
    # nixos-generate-config when installing to a software RAID device, so the
    # standard installation procedure should be unaffected. If you have custom
    # configs relying on mdraid, ensure that you use stateVersion correctly or
    # set boot.swraid.enable manually. On systems with an updated stateVersion
    # we now also emit warnings if mdadm.conf does not contain the minimum
    # required configuration necessary to run the dynamically enabled monitoring
    # daemons.
    swraid = {
      enable = true;
      # mdadmConf = config.environment.etc."mdadm.conf".text;
      mdadmConf = ''
        HOMEHOST <ignore>
        MAILADDR root
      '';
    };

    supportedFilesystems = {
      "cifs" = true;
    };
  };

  # The mdadm RAID1s were created with 'mdadm --create ... --homehost=hetzner',
  # but the hostname for each machine may be different, and mdadm's HOMEHOST
  # setting defaults to '<system>' (using the system hostname).
  # This results mdadm considering such disks as "foreign" as opposed to
  # "local", and showing them as e.g. '/dev/md/hetzner:root0'
  # instead of '/dev/md/root0'.
  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines, so we tell mdadm to
  # ignore the homehost entirely.
  environment = {
    etc."mdadm.conf".text = ''
      HOMEHOST <ignore>
      MAILADDR root
    '';

    systemPackages = with pkgs; [
      git
      du-dust
      ncdu
      # helix

      sshfs

      virter
    ];
  };

  programs = {
    mosh.enable = true;
    mtr.enable = true;
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up \
        --advertise-exit-node --exit-node
    '';
      # -authkey ${config.age.secrets.tailscale_authkey}
  };


  networking = {
    hostName = "corrino";
    domain = "emile.space";

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    useDHCP = false;
    interfaces = {
      "enp35s0" = {
        ipv4.addresses = [
          { address = "135.181.142.139"; prefixLength = 26; }
        ];
      };
      "enp35s0".ipv6.addresses = [
        { address = "2a01:4f9:3a:16a4::1"; prefixLength = 64; }
      ];
    };

    defaultGateway = "135.181.142.129";
    defaultGateway6 = { address = "fe80::1"; interface = "enp35s0"; };

    nameservers = [ "8.8.8.8" "8.8.4.4" ];


    firewall = {
      enable = true;
      allowedTCPPorts = [
        80 443 # normal web
      ];
      allowedUDPPorts = [
        51820 # wireguard
      ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
      ];

      interfaces."tailscale0".allowedTCPPorts = [
        8085 # random internal web server port
      ];
    };

    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "enp35s0";
      internalInterfaces = [ "wg0" "ve-+"];
    };

    wireguard = {
      enable = true;
      interfaces."wg0" = {
        ips = [ "10.87.0.1/24" ];
        listenPort = 51820;
        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.87.0.0/24 -o eth0 -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.87.0.0/24 -o eth0 -j MASQUERADE
        '';

        privateKeyFile = config.age.secrets.wireguard_privatekey.path;

        peers = [
          # List of allowed peers.
          { # Emiles-MBA
            publicKey = "Ebsjn7w2FeUs5lUN6ALoUcF/o9/+SopDL324YJPSCDY=";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.87.0.2/32" ];
          }
          { # Emiles-IphoneX
            publicKey = "xGfmwraI0Eh3eFEXjJrd2AYCgUM1uK4Y+FX5ACAQZ3M=";
            # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
            allowedIPs = [ "10.87.0.3/32" ];
          }
        ];
      };
    };
  };

  # Initial empty root password for easy login:
  users.users = {
    root = {
      initialHashedPassword = "";
      openssh.authorizedKeys.keys = [] ++ keys.emile;
      packages = with pkgs; [
        mdadm
        tailscale

        # random useful stuff
        htop
        git
        vim
        fd ripgrep
      ];
      extraGroups = [ "docker" "libvirtd" ];
    };

    hack = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [] ++ keys.emile;
      extraGroups = [ "docker" "libvirtd" ];
    };

    tmpuser1 = {
      isNormalUser = true;

      # TODO(emile): readd after the whole user system is setup
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMMq7gVuOuJEuarcsss2pb4JJS39zW/Fuow0foyqlV5 noobtracker@noobtracker-linux"

      openssh.authorizedKeys.keys = [] ++ keys.emile;
    };
  };

  services = {
    openssh = {
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
      enable = true;
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    tailscale = {
      enable = true;

      # use corrino as a subnet router and an exit node
      useRoutingFeatures = "both";
    };
  };
  
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };

    extraOptions = ''
      builders-use-substitutes = true
      allowed-uris = ssh://git@emile.space
    '';
    # allowed-uris = git.emile.space: gitea@git.emile.space: ssh://gitea@git.emile.space/hanemile/hefe-internal.git git+ssh: git+https:

    # settings.allowed-uris = [
    #   "ssh://"
    # ];

    buildMachines = [
      {
        hostName = "localhost";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 1;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
      {
        hostName = "caladan";
        system = "aarch64-darwin";
        protocol = "ssh-ng";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
    ];

  	distributedBuilds = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      # none :D
    ];
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "admin+acme@emile.space";
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.unstable.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
  };
  # programs.virt-manager.enable = true;

  fileSystems."/proc" = {
    device = "/proc";
    options = [
      "nosuid" "nodev" "noexec" "relatime" # normal foo
      "hidepid=2" # this makes sure users can only see their own processes
    ];
  };

  fileSystems."/mnt/storagebox-bx11" = {
    device = "//u331921.your-storagebox.de/backup";
    fsType = "cifs";
    options =
      let
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=${config.age.secrets.storage_box_bx11_password.path}"];
  };

  # FIXME
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?
}
