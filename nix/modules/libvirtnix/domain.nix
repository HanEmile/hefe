{ pkgs, lib, ... }:

{
  options = with lib; {

    # meta, this allows defining the package used for each vm individually, defaults should be sane
    packages = mkOption {
      type = types.submodule {
        options = {
          libvirt = mkPackageOption pkgs "libvirt" { };
          qemu = mkPackageOption pkgs "qemu" { };
        };
      };
    };

    # attributs for the root `<domain ...>` node
    type = mkOption {
      type = types.enum [
        "xen"
        "hvm"
        "kvm"
        "qemu"
        "lxc"
      ];
      default = "kvm";
      example = "qemu";
      description = ''
        				hypervisor used for running the domain

        				allowed values are driver specific, if missing, plz send PR

        				hvm since since 8.1.0 and QEMU 2.12
        			'';
    };

    id = mkOption {
      type = types.int;
      default = 0;
      example = 42;
    };

    # General metadata
    name = mkOption {
      type = types.str;
      example = "MyGuest";
    };

    uuid = mkOption {
      type = types.str;
      example = "3e3fce45-4f53-4fa7-bb32-11f34168b82b";
    };

    genid = mkOption {
      type = types.str;
      example = "43dc0cf8-809b-4adb-9bea-a9abb5f3d90e";
    };

    title = mkOption {
      type = types.str;
      example = "A short description - title - of the domain";
    };

    description = mkOption {
      type = types.str;
      example = "Some human readable description";
    };

    metadata = mkOption {
      type = types.str;
      default = "";
      example = ''
        			  <metadata>
        			    <app1:foo xmlns:app1="http://app1.org/app1/">..</app1:foo>
        			    <app2:bar xmlns:app2="http://app1.org/app2/">..</app2:bar>
        			  </metadata>
        			'';
    };

    os = mkOption {
      type = types.submodule {
        options = {
          firmware = mkOption {
            type = types.enum [
              "bios"
              "efi"
            ];
            default = "efi";
            example = "bios";
          };
          type = mkOption {
            type = types.enum [
              "hvm"
              "linux"
            ];
            default = "hvm";
            example = "linux";
          };
          arch = mkOption { type = types.str; };
          machine = mkOption { type = types.str; };

          # TODO(emile): features
          # Search for the following...
          # > When using firmware auto-selection there are different features enabled in the firmwares
          # ... here: https://libvirt.org/formatdomain.html
          # can't bother to implement this now

          # features = mkOption {
          # 	type = types.submodule {
          # 		options = {
          # 			enabled = {
          # 				type = types.enum [ "yes" "no" ];
          # 			};
          # 			name = {};
          # 		};
          # 	};
          # };

          # such as:
          # <loader readonly='yes' secure='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
          loader = mkOption {
            type = types.submodule {
              options = {
                readonly = mkOption {
                  type = types.enum [
                    "yes"
                    "no"
                  ];
                };
                type = mkOption {
                  type = types.enum [
                    "rom"
                    "pflash"
                  ];
                };
                secure = mkOption {
                  type = types.enum [
                    "yes"
                    "no"
                  ];
                };
                stateless = mkOption {
                  type = types.enum [
                    "yes"
                    "no"
                  ];
                };
                format = mkOption {
                  type = types.enum [
                    "raw"
                    "qcow2"
                  ];
                };
                value = mkOption {
                  type = types.str;
                  example = "/usr/share/OVMF/OVMF_CODE.fd";
                };
              };
            };
          };

          # <nvram type='network'>
          #   <source protocol='iscsi' name='iqn.2013-07.com.example:iscsi-nopool/0'>
          #     <host name='example.com' port='6000'/>
          #     <auth username='myname'>
          #       <secret type='iscsi' usage='mycluster_myname'/>
          #     </auth>
          #   </source>
          # </nvram>

          # nvram = {
          # 	type = "network";
          # 	source = {
          # 		protocol = "iscsi";
          # 		name = "iqn.2013-07.com.example:iscsi-nopool/0";
          # 	};
          # };

          nvram = mkOption {
            type = types.submodule {
              options = {
                type = mkOption {
                  type = types.enum [
                    "file"
                    "block"
                    "dir"
                    "network"
                    "volume"
                    "nvme"
                    "vhostuser"
                    "vhostvdpa"
                  ];
                  default = "";
                };

                source = mkOption {
                  type = types.submodule {
                    options = {
                      # TODO(emile): figure out how to conditionally allow setting the options below
                      #              if the type defined above has been set

                      # if type == file
                      file = mkOption { type = types.str; };
                      fdgroup = mkOption { type = types.str; };

                      # if type == block
                      dev = mkOption { type = types.str; };

                      # if type == dir
                      dir = mkOption { type = types.str; };

                      # if type == network
                      protocol = mkOption {
                        type = types.enum [
                          "nbd"
                          "iscsi"
                          "rbd"
                          "sheepdog"
                          "gluster"
                          "vxhs"
                          "nfs"
                          "http"
                          "https"
                          "ftp"
                          "ftps"
                          "tftp"
                          "ssh"
                        ];
                      };
                      name = mkOption { type = types.str; };
                      tls = mkOption {
                        type = types.enum [
                          "yes"
                          "no"
                        ];
                      };
                      tlsHostname = mkOption { type = types.str; };
                      query = mkOption { type = types.str; };

                      # if type == volume
                      pool = mkOption { type = types.str; };
                      volume = mkOption { type = types.str; };
                      mode = mkOption {
                        type = types.enum [
                          "direct"
                          "host"
                        ];
                        default = "host";
                      };

                      # if type == nvme
                      type = mkOption {
                        type = types.enum [ "pci" ];
                        default = "pci";
                        description = ''
                          													When the type is `nvme`, only `pci` is supported
                          													When the type is `vhostuser`, only `unix` is supported

                          													(I've got not clue how to model this is nix, it's essentially an attribute that is overloaded based on another value)
                          												'';
                      };
                      managed = mkOption {
                        type = types.enum [
                          "yes"
                          "no"
                        ];
                      };
                      namespace = mkOption {
                        type = types.int;
                        default = 0;
                      };

                      # if type == vhostuser
                      # type = see the type in the nvme section above
                      path = mkOption { type = types.str; };

                      # if type == vhostvdpa
                      # dev = (defined above in the "type == block" section)

                      # if type == file
                      # if type == block
                      # if type == volume
                      seclabel = mkOption { type = types.str; };

                      index = mkOption {
                        type = types.int;
                        default = 0;
                      };

                      # TODO(emile): implement checks here
                      # start here and scroll down a bit to the table
                      # https://libvirt.org/formatdomain.html#hard-drives-floppy-disks-cdroms
                      # if type == network
                      host = mkOption {
                        type = types.submodule {
                          options = {
                            name = mkOption { type = types.str; };
                            port = mkOption {
                              type = types.int;
                              default = 0;
                            };
                            transport = mkOption { type = types.str; };
                            socket = mkOption { type = types.str; };

                          };
                        };
                      };

                      snapshot = mkOption {
                        type = types.submodule {
                          options = {
                            name = mkOption { type = types.str; };
                          };
                        };
                      };

                      config = mkOption {
                        type = types.submodule {
                          options = {
                            file = mkOption { type = types.str; };
                          };
                        };
                      };

                      # Since 3.9.0, the auth element is supported for a disk type "network" that is using a source element with the protocol attributes "rbd", "iscsi", or "ssh".
                      auth = mkOption {
                        type = types.submodule {
                          options = {
                            type = mkOption {
                              # type = types.enum [ "chap" ];
                              # freeform, yet "chap" is one of the allowed options, I don't know others (yet)
                              type = types.str;
                            };
                            username = mkOption { type = types.str; };

                            # https://libvirt.org/formatsecret.html
                            secret = mkOption {
                              type = types.submodule {
                                options = {
                                  ephemeral = mkOption {
                                    type = types.enum [
                                      "yes"
                                      "no"
                                    ];
                                    default = "no";
                                  };
                                  private = mkOption {
                                    type = types.enum [
                                      "yes"
                                      "no"
                                    ];
                                    default = "no";
                                  };

                                  uuid = types.submodule {
                                    options = {
                                      value = mkOption {
                                        type = types.str;
                                        default = "";
                                      };
                                    };
                                  };
                                  description = types.submodule {
                                    options = {
                                      value = mkOption {
                                        type = types.str;
                                        default = "";
                                      };
                                    };
                                  };

                                  usage = types.submodule {
                                    options = {
                                      type = mkOption {
                                        type = types.enum [
                                          "volume"
                                          "ceph"
                                          "iscsi"
                                          "tls"
                                          "vtpm"
                                        ];
                                        default = "";
                                      };
                                      value = mkOption {
                                        type = types.str;
                                        default = "";
                                      };

                                      name = mkOption {
                                        type = types.submodule {
                                          options = {
                                            value = mkOption { type = types.str; };
                                          };
                                        };
                                      };

                                      volume = mkOption {
                                        type = types.submodule {
                                          options = {
                                            value = mkOption { type = types.str; };
                                          };
                                        };
                                      };

                                      # when using the "iscsi" type
                                      target = mkOption {
                                        type = types.submodule {
                                          options = {
                                            value = mkOption { type = types.str; };
                                          };
                                        };
                                      };

                                    };
                                  };

                                };
                              };
                            }; # end of secret

                          };
                        };
                      }; # end of auth

                      # https://libvirt.org/formatstorageencryption.html
                      encryption = mkOption {
                        type = types.submodule {
                          options = {
                            type = mkOption { type = types.str; };

                            # mandatory
                            format = mkOption {
                              type = types.enum [
                                "default"
                                "qcow"
                                "luks"
                                "luks2"
                                "luks-any"
                              ];
                            };

                            engine = mkOption {
                              type = types.enum [
                                "qemu"
                                "librbd"
                              ];
                            };

                            secrets = mkOption {
                              type = types.listOf (mkOption {
                                type = types.submodule {
                                  options = {

                                    # mandatory
                                    type = mkOption { type = types.enum [ "volume" ]; };

                                    # uuid or usage
                                    uuid = mkOption { type = types.str; };
                                    usage = mkOption { type = types.str; };

                                  };
                                };
                              });
                            }; # end of secrets

                            cipher = mkOption {
                              type = types.submodule {
                                options = {
                                  name = mkOption {
                                    type = types.str;
                                    example = "'aes', 'des', 'cast5', 'serpent', 'twofish', etc.";
                                  };
                                  size = mkOption {
                                    type = types.str;
                                    example = "'256', '192', '128', etc.";
                                  };
                                  mode = mkOption {
                                    type = types.str;
                                    example = "'cbc', 'xts', 'ecb', etc.";
                                  };
                                  hash = mkOption {
                                    type = types.str;
                                    example = "'md5', 'sha1', 'sha256', etc.";
                                  };
                                };
                              };
                            }; # end of cipher

                            ivgen = mkOption {
                              type = types.submodule {
                                options = {
                                  name = mkOption {
                                    type = types.str;
                                    example = "'plain', 'plain64', 'essiv', etc.";
                                  };
                                  hash = mkOption {
                                    type = types.str;
                                    example = "'md5', 'sha1', 'sha256'";
                                  };
                                };
                              };
                            }; # end of ivygen
                          };
                        };
                      }; # end of encryption

                      # TODO(emile): reservations
                      # Looking at the following, it seems like this can use the source element recursively
                      # Haven't looked into how to define recursive nix options yet...
                      # https://github.com/virt-manager/virt-manager/blob/5ddd3456a0ca9836a98fc6ca4f0b2eaab268bf47/tests/data/cli/compare/virt-install-many-devices.xml#L398-L400

                      # TODO(emile): initiator

                      # Based on this here:
                      # https://github.com/virt-manager/virt-manager/blob/5ddd3456a0ca9836a98fc6ca4f0b2eaab268bf47/tests/data/cli/compare/virt-install-many-devices.xml#L440
                      address = mkOption {
                        type = types.submodule {
                          options = {
                            domain = mkOption { type = types.int; };
                            bus = mkOption { type = types.int; };
                            slot = mkOption { type = types.int; };
                            function = mkOption { type = types.int; };
                          };
                        };
                      }; # end of address

                      # TODO(emile): slices
                      # Didn't find any usage of it, why is there documentation for it then?

                      ssl = mkOption {
                        type = types.submodule {
                          options = {
                            verify = mkOption {
                              type = types.enum [
                                "yes"
                                "no"
                              ];
                            };
                          };
                        };
                      }; # end of ssl

                      # TODO(emile): cookies for http and https

                      readahead = mkOption {
                        type = types.submodule {
                          options = {
                            size = mkOption { type = types.int; };
                          };
                        };
                      }; # end of readahead

                      timeout = mkOption {
                        type = types.submodule {
                          options = {
                            seconds = mkOption { type = types.int; };
                          };
                        };
                      }; # end of timeout

                      identity = mkOption {
                        type = types.submodule {
                          options = {
                            user = mkOption { type = types.str; };
                            group = mkOption { type = types.str; };

                            # if ssh
                            # required
                            username = mkOption { type = types.str; };

                            # one of these:
                            agentsock = mkOption { type = types.str; };
                            keyfile = mkOption { type = types.str; };
                          };
                        };
                      }; # end of identity

                      # disk type "vhostuser"
                      reconnect = mkOption {
                        type = types.submodule {
                          options = {
                            # mandatory
                            enabled = mkOption {
                              type = types.enum [
                                "yes"
                                "no"
                              ];
                            };
                            timeout = mkOption {
                              type = types.int;
                              description = "seconds";
                            };

                            # optional for disk type network and protocol nbd
                            delay = mkOption {
                              type = types.int;
                              default = 0;
                              description = "seconds";
                            };
                          };
                        };
                      }; # end of reconnect

                      # disk type "ssh"
                      knownHosts = mkOption {
                        type = types.submodule {
                          options = {
                            path = mkOption { type = types.str; };
                          };
                        };
                      }; # end of knownHosts

                      dataStore = mkOption {
                        type = types.submodule {
                          options = {
                            # TODO(emile): can accept the same types as a `source` element
                            type = mkOption { type = types.str; };

                            # TODO(emile): can accept format and source subelements
                            # this is (once again) recursive for the source, stil need to figure
                            # out how to handle this, just not now
                          };
                        };
                      }; # end of dataStore

                      startupPolicy = mkOption {
                        type = types.enum [
                          "mandatory"
                          "requisite"
                          "optional"
                        ];
                        default = "mandatory";
                      }; # end of startupPolicy

                      backingStore = mkOption {
                        type = types.submodule {
                          options = {
                            type = mkOption {
                              # TODO(emile): can accept the same types as a `source` element
                              type = types.str;
                            };

                            index = mkOption {
                              # TODO(emile): figure out if this can just be an int
                              type = types.str;
                            };

                            # TODO(emile): can use the following sub elements:
                            # - format
                            # - source
                            # - backingStore
                          };
                        };
                      }; # end of backingStore

                      mirror = mkOption {
                        type = types.submodule {
                          options = {
                            api = mkOption {
                              type = types.enum [
                                "copy"
                                "active-commit"
                              ];
                            };
                            ready = mkOption {
                              type = types.enum [
                                "yes"
                                "abort"
                                "pivot"
                              ];
                            };
                            # TODO(emile): can use the following sub elements:
                            # - type (disk types)
                            # - format
                            # - source
                            # - file
                          };
                        };
                      }; # end of mirror

                    };
                  };
                }; # end of source

              };
            };
          }; # end of nvram

        };
      };
    };

    memory = lib.mkOption {
      type = lib.types.int;
      default = 1024;
      example = 2048;
      description = ''
        The amount of memory to provide to the VM
      '';
    };
  };
}
