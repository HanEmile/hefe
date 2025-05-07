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
      };
    };
  };
}
