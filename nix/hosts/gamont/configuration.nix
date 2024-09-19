{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = "nixos";
  password = "";
  SSID = "%p%p%p";
  SSIDpassword = "";
  interface = "wlan0";
  hostname = "gamont";
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew emile@caladan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzLZ56SEgwZZ0OusTdSDDhpMlxSg1zPNdRLuxKOfrR5 emile@chusuk"
  ];
in
{

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ interface ];
    };

    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.1.1";
          prefixLength = 24;
        }
      ];
    };

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0;            
            accept
          }

          chain output {
            type filter hook output priority 0;
            accept
          }
          
          chain forward {
            type filter hook forward priority 0;
            accept
          }
        }

        table ip nat {
        	chain postrouting {
        		type nat hook postrouting priority srcnat; policy accept;
        		masquerade
        	}
        }
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    helix
    vim
    dnsmasq
    tcpdump
    curl
    iptables
    nftables
  ];

  services = {
    openssh.enable = true;
    dnsmasq = {
      enable = true;
      settings = {
        server = [
          "8.8.8.8"
          "8.8.4.4"
        ];
        dhcp-authoritative = true;
        domain-needed = true;
        dhcp-range = [ "192.168.1.10,192.168.1.254" ];

        interface = [ "end0" ];

      };
    };
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = keys;
    };

    users.root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
