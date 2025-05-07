{ config, lib, ... }:

let
  mkTag = import ./xml.nix { inherit lib; };
  pkgs = import <nixpkgs> { };

  stringOption =
    {
      default ? "",
    }:
    lib.mkOption {
      type = lib.types.str;
      default = "${default}";
    };
in
{
  options = {
    services.emile.libvirtnix =
      let
        cpu = lib.mkOption {
          type = lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.str;
                example = "host-passthrough";
                default = "";
              };
              check = lib.mkOption {
                type = lib.types.str;
                example = "none";
                default = "";
              };
              migratable = lib.mkOption {
                type = lib.types.str;
                example = "on";
                default = "";
              };
            };
          };
        };

        features = lib.mkOption {
          type = lib.types.submodule {
            options = {
              acpi = lib.mkEnableOption "enable acpi";
              apic = lib.mkEnableOption "enable apic";

              vmport = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    state = lib.mkOption {
                      type = lib.types.str;
                      example = "off";
                      default = "";
                    };
                  };
                };
              };
            };
          };
        };
      
        os_boot = lib.mkOption {
          type = lib.types.submodule {
            options = {
              dev = lib.mkOption {
                type = lib.types.str;
                example = "hd";
                default = "";
              };
            };
          };
        };
      
        os_nvram = lib.mkOption {
          type = lib.types.submodule {
            options = {
              value = lib.mkOption {
                type = lib.types.str;
                example = "/var/lib/libvirt/qemu/nvram/fileserver2_VARS.fd";
                default = "";
              };
            };
          };
        };
      
        os_loader = lib.mkOption {
          type = lib.types.submodule {
            options = {
              readonly = lib.mkOption {
                type = lib.types.str;
                example = "yes";
                default = "";
              };
              type = lib.mkOption {
                type = lib.types.str;
                example = "pflash";
                default = "";
              };
              value = lib.mkOption {
                type = lib.types.str;
                example = "/usr/share/OVMF/OVMF_CODE.fd";
                default = "";
              };
            };
          };
        };
      
        os_type = lib.mkOption {
          type = lib.types.submodule {
            options = {
              arch = lib.mkOption {
                type = lib.types.str;
                example = "x86_64";
                default = "";
              };
              machine = lib.mkOption {
                type = lib.types.str;
                example = "pc-q35-3.1";
                default = "";
              };
              value = lib.mkOption {
                type = lib.types.str;
                example = "hvm";
                default = "";
              };
            };
          };
        };

        os = lib.mkOption {
          description = "os";
          type = lib.types.submodule {
            options = {
              type = os_type;
              loader = os_loader;
              nvram = os_nvram;
              boot = os_boot;
            };
          };
        };

        resource = lib.mkOption {
          description = "resource";
          type = lib.types.submodule {
            options = {
              partition = lib.mkOption {
                type = lib.types.str;
                example = "/machine";
                default = "";
              };
            };
          };
        };

        vcpu = lib.mkOption {
          description = "vcpu";
          type = lib.types.submodule {
            options = {
              placement = lib.mkOption {
                # TODO(emile): fill up
                type = lib.types.enum [ "static" ];
                example = "static";
                default = "static";
              };
              count = lib.mkOption {
                type = lib.types.int;
                example = 4;
                default = 1;
              };
            };
          };
        };

        mem = lib.mkOption {
          description = "memory";
          type = lib.types.submodule {
            options = {
              unit = lib.mkOption {
                # TODO(emile): fill up
                type = lib.types.enum [
                  "KiB"
                  "MiB"
                  "GiB"
                  "TiB"
                ];
                example = "KiB";
                default = "KiB";
              };
              value = lib.mkOption {
                type = lib.types.int;
                example = 2097152;
                default = 1000;
              };
            };
          };
        };

        memory = mem;
        currentMemory = mem;

        metadata = lib.mkOption {
          description = "metadata submodule";
          type = lib.types.submodule {
            options = {
              libosinfo = lib.mkOption {
                type = lib.types.str;
                example = "https://libosinfo.org/xmlns/libvirt/domain/1.0";
                default = "";
              };
              libosinfo_os = lib.mkOption {
                type = lib.types.str;
                example = "https://nixos.org/nixos/unknown";
                default = "";
              };
            };
          };
        };

        vm = lib.types.submodule {
          options = {
            vm_type = stringOption { default = "kvm"; };
            id = stringOption { };
            name = stringOption { };
            uuid = stringOption { };

            inherit
              metadata
              memory
              currentMemory
              vcpu
              resource
              os
              features
              cpu
              ;
          };
        };
      in
      {
        enable = lib.mkEnableOption "Enable r2wars-web";
      

        # Temporary output we write the domain to, in order to inspect the correctness of
        # the generated xml
        output.domain = lib.mkOption { type = lib.types.path; };

        # An attrset of VMs
        vm = lib.mkOption {
          description = "VMs to define";
          type = lib.types.attrsOf vm;
        };
      };
  };

  config = lib.mkIf config.services.emile.libvirtnix.enable {
    services.emile.libvirtnix =
      let
        vm = config.services.emile.libvirtnix.vm;

        cpu =
          vm_name:
          mkTag {
            name = "cpu";
            args = let
              mode = vm.${vm_name}.cpu.mode;
              check = vm.${vm_name}.cpu.check;
              migratable= vm.${vm_name}.cpu.migratable;
            in [
              (if (mode != null)
               then {key = "mode"; val = mode;}
               else "")
              (if (check != null)
               then {key = "check"; val = check;}
               else "")
              (if (migratable != null)
               then {key = "migratable"; val = migratable;}
               else "")
            ];
            closing = false;
          };
        
        features =
          vm_name:
          mkTag {
            name = "features";
            children = let
              acpi = vm_name: mkTag {
                name = "acpi";
                closing = false;
              };
              apic = vm_name: mkTag {
                name = "apic";
                closing = false;
              };
              vmport = vm_name: mkTag {
                name = "vmport";
                args = [
                  { key = "state"; val = vm.${vm_name}.features.vmport.state; }
                ];
                closing = false;
              };
            in [
              (if (vm.${vm_name}.features.acpi != false) then (acpi vm_name) else "")
              (if (vm.${vm_name}.features.apic != false) then (apic vm_name) else "")
              (if (vm.${vm_name}.features.vmport != null) then (vmport vm_name) else "")
            ];
          };

        os =
          vm_name:
          mkTag {
            name = "os";
            children = let
              os_type = vm_name: mkTag {
                name = "type";
                args = [
                  { key = "arch"; val = vm.${vm_name}.os.type.arch; }
                  { key = "machine"; val = vm.${vm_name}.os.type.machine; }
                ];
                value = vm.${vm_name}.os.type.value;
              };
              os_loader = vm_name: mkTag {
                name = "loader";
                args = [
                  { key = "readonly"; val = vm.${vm_name}.os.loader.readonly; }
                  { key = "pflash"; val = vm.${vm_name}.os.loader.type; }
                ];
                value = vm.${vm_name}.os.loader.value;
              };
              os_nvram = vm_name: mkTag {
                name = "nvram";
                value = vm.${vm_name}.os.nvram.value;
              };
              os_boot = vm_name: mkTag {
                name = "type";
                args = [
                  { key = "dev"; val = vm.${vm_name}.os.boot.dev; }
                ];
                closing = false;
              };
            in [
              (os_type vm_name)
              (os_loader vm_name)
              (os_nvram vm_name)
              (os_boot vm_name)
            ];
          };

        resource =
          vm_name:
          mkTag {
            name = "resource";
            children = [
              (mkTag {
                name = "partition";
                value = "${toString vm.${vm_name}.resource.partition}";
              })
            ];
          };

        vcpu =
          vm_name:
          mkTag {
            name = "vcpu";
            args = [
              {
                key = "placement";
                val = vm.${vm_name}.vcpu.placement;
              }
            ];
            value = "${toString vm.${vm_name}.vcpu.count}";
          };

        currentMemory =
          vm_name:
          mkTag {
            name = "currentMemory";
            args = [
              {
                key = "unit";
                val = vm.${vm_name}.currentMemory.unit;
              }
            ];
            value = "${toString vm.${vm_name}.currentMemory.value}";
          };
        memory =
          vm_name:
          mkTag {
            name = "memory";
            args = [
              {
                key = "unit";
                val = vm.${vm_name}.memory.unit;
              }
            ];
            value = "${toString vm.${vm_name}.memory.value}";
          };

        libosinfo_os =
          vm_name:
          mkTag {
            name = "libosinfo:os";
            args = [
              {
                key = "id";
                val = vm.${vm_name}.metadata.libosinfo_os;
              }
            ];
            closing = false;
          };

        libosinfo_libosinfo =
          vm_name:
          mkTag {
            name = "libosinfo:libosinfo";
            args = [
              {
                key = "xmlns:libosinfo";
                val = vm.${vm_name}.metadata.libosinfo;
              }
            ];
            children = [
              (libosinfo_os vm_name)
            ];
          };

        metadata =
          vm_name:
          mkTag {
            name = "metadata";
            children = [ (libosinfo_libosinfo vm_name) ];
          };

        uuid =
          vm_name:
          mkTag {
            name = "uuid";
            value = vm.${vm_name}.uuid;
          };

        name =
          vm_name:
          mkTag {
            name = "name";
            value = vm.${vm_name}.name;
          };

        # the vm_name has to be passed in, as we want to accesses the value for the given vm when
        # generating the config
        domain =
          vm_name:
          mkTag {
            name = "domain";
            args = [
              {
                key = "type";
                val = vm.${vm_name}.vm_type;
              }
              {
                key = "id";
                val = vm.${vm_name}.id;
              }
            ];
            children = [
              (name vm_name)
              (uuid vm_name)
              (metadata vm_name)
              (memory vm_name)
              (currentMemory vm_name)
              (vcpu vm_name)
              (resource vm_name)
              (os vm_name)
              (features vm_name)
              (cpu vm_name)
            ];
          };
      in
      {
        output.domain = pkgs.writeText "libvirt-domain-config.xml" (domain "alan");
      };
  };
}
