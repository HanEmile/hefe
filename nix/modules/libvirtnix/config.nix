{
  services.emile.libvirtnix = {
    enable = true;
    vm = {
      "alan" = {
        vm_type = "kvm";
        id = "1337";
        name = "blub";
        uuid = "cafebabe-d474-452b-80f4-c951c39bcf74";

        metadata.libosinfo = "https://libosinfo.org/xmlns/libvirt/domain/1.0";
        metadata.libosinfo_os = "https://nixos.org/nixos/unknown";

        memory.unit = "KiB";
        memory.value = 2097152;

        currentMemory.unit = "KiB";
        currentMemory.value = 2097152;

        vcpu.placement = "static";
        vcpu.count = 3;

        resource.partition = "/machine";

        os = {
          type = {
            arch = "x86_64";
            machine = "pc-q35-3.1";
            value = "hvm";
          };

          loader = {
            readonly = "yes";
            type = "pflash";
            value = "/usr/share/OVMF/OVMF_CODE.fd";
          };

          nvram.value = "/var/lib/libvirt/qemu/nvram/fileserver2_VARS.fd";

          boot.dev = "hd";
        };

        features = {
          acpi = true;
          apic = true;
          vmport = {
            state = "off";
          };
        };

        cpu = {
          mode = "host-passthrough";
          check = "none";
          migratable = "on";
        };

        clock = {
          offset = "utc";
          timer = [
            {
              name = "rtc";
              tickpolicy = "catchup";
            }
            {
              name = "pit";
              tickpolicy = "delay";
            }
            {
              name = "hpet";
              present = "no";
            }
          ];
        };

        on_poweroff = "destroy";
        on_reboot = "restart";
        on_crash = "destroy";

        pm = {
          suspend-to-mem = "no";
          suspend-to-disk = "no";
        };

        devices = {
          emulators = [
            {
              value = "/usr/bin/qemu-system-x86_64";
            }
          ];

          disks = [
            {
              type = "block";
              device = "disk";
              driver = {
                name = "qemu";
                type = "raw";
                cache = "none";
                io = "native";
                discard = "unmap";
              };
              source = {
                dev = "/dev/vmstorage/fileserver2";
                index = 3;
              };
              backingStore = true;
              target = {
                dev = "vda";
                bus = "virtio";
              };
              alias = {
                name = "virtio-disk0";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x04";
                slot = "0x00";
                function = "0x0";
              };
            }
            {
              type = "block";
              device = "disk";
              driver = {
                name = "qemu";
                type = "raw";
              };
              source = {
                dev = "/dev/mapper/storage1";
                index = 2;
              };
              backingStore = true;
              target = {
                dev = "vdb";
                bus = "virtio";
              };
              alias = {
                name = "virtio-disk1";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x08";
                slot = "0x00";
                function = "0x0";
              };
            }
            {
              type = "block";
              device = "disk";
              driver = {
                name = "qemu";
                type = "raw";
              };
              source = {
                dev = "/dev/maper/storage2";
                index = 1;
              };
              backingStore = true;
              target = {
                dev = "vdc";
                bus = "virtio";
              };
              alias = {
                name = "virtio-disk2";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x09";
                slot = "0x00";
                function = "0x0";
              };
            }
          ];

          controllers = [
            {
              type = "usb";
              index = 0;
              model = "qemu-xhci";
              ports = 15;
              alias = {
                name = "usb";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x02";
                slot = "0x00";
                function = "0x0";
              };
            }
            {
              type = "pci";
              index = 0;
              model = "pci-root";
              alias = {
                name = "pcie.0";
              };
            }
            {
              type = "pci";
              index = 1;
              model = "pcie-root-port";
              target = {
                chassis = 1;
                port = "0x10";
              };
              alias = {
                name = "pci.1";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x0";
                multifunction = "on";
              };
            }
            {
              type = "pci";
              index = 2;
              model = "pcie-root-port";
              target = {
                chassis = 2;
                port = "0x11";
              };
              alias = {
                name = "pci.2";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x0";
                multifunction = "on";
              };
            }
            {
              type = "pci";
              index = 3;
              model = "pcie-root-port";
              target = {
                chassis = 3;
                port = "0x12";
              };
              alias = {
                name = "pci.3";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x2";
              };
            }
            {
              type = "pci";
              index = 4;
              model = "pcie-root-port";
              target = {
                chassis = 4;
                port = "0x13";
              };
              alias = {
                name = "pci.4";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x3";
              };
            }
            {
              type = "pci";
              index = 5;
              model = "pcie-root-port";
              target = {
                chassis = 5;
                port = "0x14";
              };
              alias = {
                name = "pci.5";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x4";
              };
            }
            {
              type = "pci";
              index = 6;
              model = "pcie-root-port";
              target = {
                chassis = 6;
                port = "0x15";
              };
              alias = {
                name = "pci.6";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x5";
              };
            }
            {
              type = "pci";
              index = 7;
              model = "pcie-root-port";
              target = {
                chassis = 7;
                port = "0x16";
              };
              alias = {
                name = "pci.7";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x6";
              };
            }
            {
              type = "pci";
              index = 8;
              model = "pcie-root-port";
              target = {
                chassis = 8;
                port = "0x17";
              };
              alias = {
                name = "pci.8";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x02";
                function = "0x7";
              };
            }
            {
              type = "pci";
              index = 9;
              model = "pcie-root-port";
              target = {
                chassis = 9;
                port = "0x18";
              };
              alias = {
                name = "pci.9";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x0";
                multifunction = "on";
              };
            }
            {
              type = "pci";
              index = 10;
              model = "pcie-root-port";
              target = {
                chassis = 10;
                port = "0x19";
              };
              alias = {
                name = "pci.10";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x1";
              };
            }
            {
              type = "pci";
              index = 11;
              model = "pcie-root-port";
              target = {
                chassis = 11;
                port = "0x1a";
              };
              alias = {
                name = "pci.11";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x2";
              };
            }
            {
              type = "pci";
              index = 12;
              model = "pcie-root-port";
              target = {
                chassis = 12;
                port = "0x1b";
              };
              alias = {
                name = "pci.12";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x3";
              };
            }
            {
              type = "pci";
              index = 13;
              model = "pcie-root-port";
              target = {
                chassis = 13;
                port = "0x1c";
              };
              alias = {
                name = "pci.13";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x4";
              };
            }
            {
              type = "pci";
              index = 14;
              model = "pcie-root-port";
              target = {
                chassis = 14;
                port = "0x1d";
              };
              alias = {
                name = "pci.14";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x5";
              };
            }
            {
              type = "pci";
              index = 15;
              model = "pcie-root-port";
              target = {
                chassis = 15;
                port = "0x1e";
              };
              alias = {
                name = "pci.15";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x03";
                function = "0x6";
              };
            }
            {
              type = "pci";
              index = 16;
              model = "pcie-root-port";
              alias = {
                name = "pci.16";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x07";
                slot = "0x00";
                function = "0x0";
              };
            }
            {
              type = "sata";
              index = 0;
              alias = {
                name = "ide";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x00";
                slot = "0x1f";
                function = "0x02";
              };
            }
            {
              type = "virtio-serial";
              index = 0;
              alias = {
                name = "virtio-serial0";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x03";
                slot = "0x00";
                function = "0x0";
              };
            }
            {
              type = "scsi";
              index = 0;
              model = "lsilogic";
              alias = {
                name = "scsi0";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x10";
                slot = "0x01";
                function = "0x0";
              };
            }
          ];
          interfaces = [
            {
              type = "bridge";
              mac = {
                address = "52:54:00:bf:ba:88";
              };
              source = {
                network = "services";
                portid = "6c3a3512-d823-4521-9043-3a91a65682f5";
                bridge = "br7";
              };
              target = {
                dev = "vnet2";
              };
              model = {
                type = "virtio";
              };
              alias = {
                name = "net0";
              };
              address = {
                type = "pci";
                domain = "0x0000";
                bus = "0x01";
                slot = "0x00";
                function = "0x0";
              };
            }
          ];
        };
      };
    };
  };
}
