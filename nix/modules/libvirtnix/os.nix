{ lib, ... }:

let
  mkOption = lib.mkOption;
  submodule = lib.types.submodule;
  types = lib.types;

  os = {
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
    
  };
in
{
  options = {
    os = mkOption {
      type = submodule {
        options = {
          inherit (os) firmware type arch machine loader;
        };
      };
    };
  };
}
