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

  # shorthand for an option with an enum, no default value
  enumOpt =
    options:
    lib.mkOption {
      type = lib.types.nullOr (lib.types.enum options);
      default = null;
    };
in
{
  options = {
    services.emile.libvirtnix =
      let

        address = lib.mkOption {
          default = null;
          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                type = enumOpt [ "pci" ];
                domain = lib.mkOption {
                  type = lib.types.str;
                  example = "0x0000";
                };
                bus = lib.mkOption {
                  type = lib.types.str;
                  example = "0x4";
                };
                slot = lib.mkOption {
                  type = lib.types.str;
                  example = "0x00";
                };
                function = lib.mkOption {
                  type = lib.types.str;
                  example = "0x00";
                };
                multifunction = lib.mkOption {
                  type = lib.types.enum [
                    "on"
                    "off"
                  ];
                  example = "on";
                  default = "off";
                };
              };
            }
          );
        };

        interface = lib.mkOption {
          type = lib.types.submodule {
            options = {
              type = enumOpt [ "bridge" ];
              mac = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    address = lib.types.mkOption {
                      type = lib.types.str;
                    };
                  };
                };
              };
              source = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    network = lib.types.mkOption {
                      type = lib.types.str;
                    };
                    portid = lib.types.mkOption {
                      type = lib.types.str;
                    };
                    bridge = lib.types.mkOption {
                      type = lib.types.str;
                    };
                  };
                };
              };
              target = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    dev = lib.types.mkOption {
                      type = lib.types.str;
                    };
                  };
                };
              };
              model = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    type = lib.types.mkOption {
                      type = enumOpt [ "virtio" ];
                    };
                  };
                };
              };
              alias = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    dev = lib.types.mkOption {
                      name = lib.types.str;
                    };
                  };
                };
              };
              inherit address;
            };
          };
        };


        controller = lib.types.submodule {
          options = {
            type = enumOpt [
              "usb"
              "pci"
              "sata"
              "virtio-serial"
              "scsi"
            ];
            index = lib.mkOption { type = lib.types.int; };
            model = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            ports = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
            };
            alias = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  name = lib.mkOption { type = lib.types.str; };
                };
              };
            };
            target = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    chassis = lib.mkOption { type = lib.types.int; };
                    port = lib.mkOption { type = lib.types.str; };
                  };
                }
              );
              default = null;
            };
            inherit address;
          };
        };

        emulator = lib.types.submodule {
          options = {
            value = lib.mkOption { type = lib.types.str; };
          };
        };

        disk = lib.types.submodule {
          options = {
            type = enumOpt [ "block" ];
            device = enumOpt [ "disk" ];
            driver = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  name = lib.mkOption { type = lib.types.str; };
                  type = enumOpt [ "raw" ];
                  cache = enumOpt [ "none" ];
                  io = enumOpt [ "native" ];
                  discard = enumOpt [ "unmap" ];
                };
              };
            };
            source = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  dev = lib.mkOption { type = lib.types.str; };
                  index = lib.mkOption { type = lib.types.int; };
                };
              };
            };
            backingStore = lib.mkOption { type = lib.types.bool; };
            target = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  dev = lib.mkOption { type = lib.types.str; };
                  bus = enumOpt [ "virtio" ];
                };
              };
            };
            alias = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  name = lib.mkOption { type = lib.types.str; };
                };
              };
            };
            inherit address;
          };
        };

        devices = lib.mkOption {
          type = lib.types.submodule {
            options = {
              emulators = lib.mkOption {
                type = lib.types.listOf emulator;
              };
              disks = lib.mkOption {
                type = lib.types.listOf disk;
              };
              controllers = lib.mkOption {
                type = lib.types.listOf controller;
              };
              interfaces = lib.mkOption {
                type = lib.types.listOf interface;
              };
            };
          };
        };

        pm = lib.mkOption {
          type = lib.types.submodule {
            options = {
              suspend-to-mem = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "yes"
                    "no"
                  ]
                );
                default = null;
                example = "yes";
              };
              suspend-to-disk = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "yes"
                    "no"
                  ]
                );
                default = null;
                example = "yes";
              };
            };
          };
        };

        on_handle = lib.mkOption {
          type = lib.types.enum [
            "destroy"
            "restart"
            "preserve"
            "rename-restart"
          ];
        };

        on_poweroff = on_handle;
        on_reboot = on_handle;
        on_crash = on_handle;

        clock = lib.mkOption {
          type = lib.types.submodule {
            options = {
              offset = lib.mkOption {
                type = lib.types.str;
                example = "utc";
                default = "utc";
              };
              timer = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.enum [
                          # "platform" (currently unsupported)
                          "hpet" # xen, qemu, lxc
                          "kvmclock" # qemu
                          "pit" # qemu
                          "rtc" # qemu, lxc
                          "tsc" # xen, qemu - since 3.2.0

                          # The hypervclock timer adds support for the reference time counter and the reference page for iTSC feature for guests running the Microsoft Windows operating system.
                          "hypervclock" # qemu - since 1.2.2

                          "armvtimer" # qemu - since 6.1.0
                        ];
                        default = "";
                        example = "";
                      };
                      track = lib.mkOption {
                        # TODO(emile): Only valid for name="rtc" or name="platform".
                        type = lib.types.enum [
                          "boot"
                          "guest"
                          "wall"
                          "realtime"
                        ];
                        default = "";
                        example = "";
                      };
                      tickpolicy = lib.mkOption {
                        type = lib.types.nullOr (
                          lib.types.enum [
                            "catchup"
                            "delay"
                            "merge"
                            "discard"
                            "catchup"
                          ]
                        );
                        default = null;
                        example = "";
                      };
                      present = lib.mkOption {
                        type = lib.types.nullOr (
                          lib.types.enum [
                            "yes"
                            "no"
                          ]
                        );
                        default = null;
                        example = "";
                      };
                    };
                  }
                );
                example = [
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
                default = [
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
            };
          };
        };

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
              clock
              on_poweroff
              on_reboot
              on_crash
              pm
              devices
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

        # try this in a nix repl
        # nix-repl> mkTag = import ./xml.nix { lib = (import <nixpkgs> {}).lib; }
        # nix-repl> :p let func = (x: mkTag {name=x.variant;}); case = {"emulator" = func; "disk" = func;}; in map (x: case."${x.variant}" x) [ {variant = "emulator"; value = "asd";} {variant = "disk"; type = "block"; } ]

        emulator =
          x:
          mkTag {
            name = "emulator";
            value = x.value;
          };

        interface =
          x:
          mkTag {
            name = "interface";
            args = [
              (
                if x.type != null then
                  {
                    key = "type";
                    val = x.type;
                  }
                else
                  ""
              )
            ];
            children = [
              # (
              #   if x.mac != null then
              #     (mkTag {
              #       name = "mac";
              #       args = [
              #         {
              #           key = "address";
              #           val = x.mac.address;
              #         }
              #       ];
              #       closing = false;
              #     })
              #   else
              #     ""
              # )
              #(
              #  if x.source != null then
              #    (mkTag {
              #      name = "source";
              #      args = [
              #        {
              #          key = "network";
              #          val = x.source.network;
              #        }
              #        {
              #          key = "portid";
              #          val = x.source.portid;
              #        }
              #        {
              #          key = "bridge";
              #          val = x.source.bridge;
              #        }
              #      ];
              #      closing = false;
              #    })
              #  else
              #    ""
              #)
              #(
              #  if x.target != null then
              #    (mkTag {
              #      name = "target";
              #      args = [
              #        {
              #          key = "dev";
              #          val = x.target.dev;
              #        }
              #      ];
              #    })
              #  else
              #    ""
              #)
              #(
              #  if x.model != null then
              #    (mkTag {
              #      name = "model";
              #      args = [
              #        {
              #          key = "type";
              #          val = x.model.type;
              #        }
              #      ];
              #    })
              #  else
              #    ""
              #)
              #(
              #  if x.alias!= null then
              #    (mkTag {
              #      name = "alias";
              #      args = [
              #        {
              #          key = "name";
              #          val = x.alias.name;
              #        }
              #      ];
              #    })
              #  else
              #    ""
              #)
              #(
              #  if x.address != null then
              #    mkTag {
              #      name = "address";
              #      args = [
              #        (
              #          if x.address.type != null then
              #            {
              #              key = "type";
              #              val = x.address.type;
              #            }
              #          else
              #            ""
              #        )
              #        {
              #          key = "domain";
              #          val = x.address.domain;
              #        }
              #        {
              #          key = "bus";
              #          val = x.address.bus;
              #        }
              #        {
              #          key = "slot";
              #          val = x.address.slot;
              #        }
              #        {
              #          key = "function";
              #          val = x.address.function;
              #        }
              #      ];
              #      closing = false;
              #    }
              #  else
              #    ""
              #)
            ];
          };

        controller =
          x:
          mkTag {
            name = "controller";
            args = [
              (
                if x.type != null then
                  {
                    key = "type";
                    val = x.type;
                  }
                else
                  ""
              )
              (
                if x.index != null then
                  {
                    key = "index";
                    val = "${toString x.index}";
                  }
                else
                  ""
              )
              (
                if x.model != null then
                  {
                    key = "model";
                    val = x.model;
                  }
                else
                  ""
              )
              (
                if x.ports != null then
                  {
                    key = "ports";
                    val = "${toString x.ports}";
                  }
                else
                  ""
              )
            ];
            children = [
              # TODO(emile): figure out if the arg in controller is really the same as the
              #              one given in model. The configs I've got let it seem so
              # <controller type="pci" index="1" model="pcie-root-port">
              #   <model name="pcie-root-port"/>
              (
                if x.model != null then
                  (mkTag {
                    name = "model";
                    args = [
                      {
                        key = "name";
                        val = x.model;
                      }
                    ];
                    closing = false;
                  })
                else
                  ""
              )
              (
                if x.target != null then
                  (mkTag {
                    name = "target";
                    args = [
                      {
                        key = "chassis";
                        val = "${toString x.target.chassis}";
                      }
                      {
                        key = "port";
                        val = x.target.port;
                      }
                    ];
                  })
                else
                  ""
              )
              (mkTag {
                name = "alias";
                args = [
                  (
                    if x.alias.name != null then
                      {
                        key = "name";
                        val = x.alias.name;
                      }
                    else
                      ""
                  )
                ];
                closing = false;
              })

              (
                if x.address != null then
                  mkTag {
                    name = "address";
                    args = [
                      (
                        if x.address.type != null then
                          {
                            key = "type";
                            val = x.address.type;
                          }
                        else
                          ""
                      )
                      {
                        key = "domain";
                        val = x.address.domain;
                      }
                      {
                        key = "bus";
                        val = x.address.bus;
                      }
                      {
                        key = "slot";
                        val = x.address.slot;
                      }
                      {
                        key = "function";
                        val = x.address.function;
                      }
                    ];
                    closing = false;
                  }
                else
                  ""
              )
            ];
          };

        disk =
          x:
          mkTag {
            name = "disk";
            args = [
              {
                key = "type";
                val = x.type;
              }
              {
                key = "device";
                val = x.device;
              }
            ];
            children = [
              (mkTag {
                name = "driver";
                args = [
                  (
                    if x.driver.name != null then
                      {
                        key = "name";
                        val = x.driver.name;
                      }
                    else
                      ""
                  )
                  (
                    if x.driver.type != null then
                      {
                        key = "type";
                        val = x.driver.type;
                      }
                    else
                      ""
                  )
                  (
                    if x.driver.cache != null then
                      {
                        key = "cache";
                        val = x.driver.cache;
                      }
                    else
                      ""
                  )
                  (
                    if x.driver.io != null then
                      {
                        key = "io";
                        val = x.driver.io;
                      }
                    else
                      ""
                  )
                  (
                    if x.driver.discard != null then
                      {
                        key = "discard";
                        val = x.driver.discard;
                      }
                    else
                      ""
                  )
                ];
                closing = false;
              })
              (mkTag {
                name = "source";
                args = [
                  {
                    key = "dev";
                    val = x.source.dev;
                  }
                  {
                    key = "index";
                    val = "${toString x.source.index}";
                  }
                ];
                closing = false;
              })
              (
                if x.backingStore == true then
                  mkTag {
                    name = "backingStore";
                    closing = false;
                  }
                else
                  ""
              )
              (mkTag {
                name = "target";
                args = [
                  {
                    key = "dev";
                    val = x.target.dev;
                  }
                  {
                    key = "bus";
                    val = x.target.bus;
                  }
                ];
                closing = false;
              })
              (mkTag {
                name = "alias";
                args = [
                  {
                    key = "name";
                    val = x.alias.name;
                  }
                ];
                closing = false;
              })
              (mkTag {
                name = "address";
                args = [
                  {
                    key = "type";
                    val = x.address.type;
                  }
                  {
                    key = "domain";
                    val = x.address.domain;
                  }
                  {
                    key = "bus";
                    val = x.address.bus;
                  }
                  {
                    key = "slot";
                    val = x.address.slot;
                  }
                  {
                    key = "function";
                    val = x.address.function;
                  }
                ];
                closing = false;
              })
            ];
            value = x.type;
          };

        devices =
          vm_name:
          mkTag {
            name = "devices";
            children =
              map (x: emulator x) vm.${vm_name}.devices.emulators
              ++ map (x: disk x) vm.${vm_name}.devices.disks
              ++ map (x: controller x) vm.${vm_name}.devices.controllers
              ++ map (x: interface x) vm.${vm_name}.devices.interfaces;
          };

        pm =
          vm_name:
          mkTag {
            name = "pm";
            children =
              let
                suspend-to-mem = mkTag {
                  name = "suspend-to-mem";
                  args = [
                    {
                      key = "enabled";
                      val = vm.${vm_name}.pm.suspend-to-mem;
                    }
                  ];
                  closing = false;
                };

                suspend-to-disk = mkTag {
                  name = "suspend-to-disk";
                  args = [
                    {
                      key = "enabled";
                      val = vm.${vm_name}.pm.suspend-to-disk;
                    }
                  ];
                  closing = false;
                };
              in
              [
                suspend-to-mem
                suspend-to-disk
              ];
          };

        on_handler =
          { vm_name, tag }:
          mkTag {
            name = "${tag}";
            value = vm.${vm_name}.${tag};
          };

        on_poweroff =
          vm_name:
          on_handler {
            inherit vm_name;
            tag = "on_poweroff";
          };
        on_reboot =
          vm_name:
          on_handler {
            inherit vm_name;
            tag = "on_reboot";
          };
        on_crash =
          vm_name:
          on_handler {
            inherit vm_name;
            tag = "on_crash";
          };

        clock =
          vm_name:
          mkTag {
            name = "clock";
            args = [
              {
                key = "offset";
                val = vm.${vm_name}.clock.offset;
              }
            ];
            children = map (
              x:
              mkTag {
                name = "timer";
                args =
                  let
                    tickpolicy =
                      if x.tickpolicy != null then
                        {
                          key = "tickpolicy";
                          val = x.tickpolicy;
                        }
                      else
                        { };

                    present =
                      if x.present != null then
                        {
                          key = "present";
                          val = x.present;
                        }
                      else
                        { };
                  in
                  [
                    {
                      key = "name";
                      val = x.name;
                    }
                    tickpolicy
                    present
                  ];
              }
            ) vm.${vm_name}.clock.timer;
          };

        cpu =
          vm_name:
          mkTag {
            name = "cpu";
            args =
              let
                mode = vm.${vm_name}.cpu.mode;
                check = vm.${vm_name}.cpu.check;
                migratable = vm.${vm_name}.cpu.migratable;
              in
              [
                (
                  if (mode != null) then
                    {
                      key = "mode";
                      val = mode;
                    }
                  else
                    ""
                )
                (
                  if (check != null) then
                    {
                      key = "check";
                      val = check;
                    }
                  else
                    ""
                )
                (
                  if (migratable != null) then
                    {
                      key = "migratable";
                      val = migratable;
                    }
                  else
                    ""
                )
              ];
            closing = false;
          };

        features =
          vm_name:
          mkTag {
            name = "features";
            children =
              let
                acpi =
                  vm_name:
                  mkTag {
                    name = "acpi";
                    closing = false;
                  };
                apic =
                  vm_name:
                  mkTag {
                    name = "apic";
                    closing = false;
                  };
                vmport =
                  vm_name:
                  mkTag {
                    name = "vmport";
                    args = [
                      {
                        key = "state";
                        val = vm.${vm_name}.features.vmport.state;
                      }
                    ];
                    closing = false;
                  };
              in
              [
                (if (vm.${vm_name}.features.acpi != false) then (acpi vm_name) else "")
                (if (vm.${vm_name}.features.apic != false) then (apic vm_name) else "")
                (if (vm.${vm_name}.features.vmport != null) then (vmport vm_name) else "")
              ];
          };

        os =
          vm_name:
          mkTag {
            name = "os";
            children =
              let
                os_type =
                  vm_name:
                  mkTag {
                    name = "type";
                    args = [
                      {
                        key = "arch";
                        val = vm.${vm_name}.os.type.arch;
                      }
                      {
                        key = "machine";
                        val = vm.${vm_name}.os.type.machine;
                      }
                    ];
                    value = vm.${vm_name}.os.type.value;
                  };
                os_loader =
                  vm_name:
                  mkTag {
                    name = "loader";
                    args = [
                      {
                        key = "readonly";
                        val = vm.${vm_name}.os.loader.readonly;
                      }
                      {
                        key = "pflash";
                        val = vm.${vm_name}.os.loader.type;
                      }
                    ];
                    value = vm.${vm_name}.os.loader.value;
                  };
                os_nvram =
                  vm_name:
                  mkTag {
                    name = "nvram";
                    value = vm.${vm_name}.os.nvram.value;
                  };
                os_boot =
                  vm_name:
                  mkTag {
                    name = "type";
                    args = [
                      {
                        key = "dev";
                        val = vm.${vm_name}.os.boot.dev;
                      }
                    ];
                    closing = false;
                  };
              in
              [
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
              (clock vm_name)
              (on_poweroff vm_name)
              (on_reboot vm_name)
              (on_crash vm_name)
              (pm vm_name)
              (devices vm_name)
            ];
          };
      in
      {
        output.domain = pkgs.writeText "libvirt-domain-config.xml" (domain "alan");
      };
  };
}
