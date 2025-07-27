{ config, lib, ... }:

# https://libvirt.org/formatsecret.html

let
  pkgs = import <nixpkgs> { };

  mkOption = lib.mkOption;
  submodule = lib.types.submodule;
  types = lib.types;
  enum = types.enum;
  str = types.str;

  yesNoOption = mkOption {
    type = enum [
      "yes"
      "no"
    ];
    default = "no";
  };
  # YesnoOption = mkOption { type = enum [ "yes" "no" ]; default = "yes"; };

  # takes a few args and creats a valid xml tag pair out of it
  #
  # testTag = mkTag {
  #   name = "name";
  #   args = [
  #     {
  #       key = "arg1";
  #       val = "arg1val";
  #     }
  #     {
  #       key = "arg2";
  #       val = "arg2val";
  #     }
  #   ];
  #   value = "qwe";
  #   children = [
  #     (mkTag { name = "nested"; args = []; value = "qwe"; children = [];})
  #   ];
  # };
  #
  # <name arg1=arg1val arg2=arg2val>
  #   value
  #   {children}
  # </name>
  mkTag =
    {
      name, # name of the tag to be used, such as `secret`, `description`, ...
      args ? [ ], # args, [ { key="a"; val="b"; } { key="c"; val="d"; } ]
      value ? "", # the value to place in the middle
      children ? [ ], # the child elements
    }:
    let
      args_str =
        " " + lib.strings.concatStrings (lib.strings.intersperse " " (map (x: "${x.key}='${x.val}'") args));
      child_evaled = lib.strings.concatStrings children;
    in
    "<${name}${lib.optionalString (args != [ ]) args_str}>${value}${child_evaled}</${name}>";

  strOption =
    {
      default ? "",
    }:
    mkOption {
      type = str;
      default = "${default}";
    };

  usage = mkOption {
    type = submodule {
      options = {
        type = mkOption {
          type = enum [
            "volume"
            "ceph"
            "iscsi"
            "tls"
            "vtpm"
          ];
          default = "";
        };

        value = strOption { };

        name = strOption { };
        volume = strOption { };
        target = strOption { };
      };
    };
  };

  secret = {
    inherit usage;

    ephemeral = yesNoOption;
    private = yesNoOption;

    uuid = strOption { };
    description = strOption { };
  };

in
{
  options = {
    services.emile.libvirtnix = {
      enable = lib.mkEnableOption "Enable r2wars-web";

      secret = mkOption {
        type = submodule {
          options = {
            inherit (secret)
              ephemeral
              private
              uuid
              description
              usage
              ;
          };
        };
      };

      # output = mkOption { type = types.path; };
    };
  };

  config = lib.mkIf config.services.emile.libvirtnix.enable {
    services.emile.libvirtnix =
      let
        secret = mkTag {
          name = "secret";
          args = [
            {
              key = "ephemeral";
              val = config.services.emile.libvirtnix.secret.ephemeral;
            }
            {
              key = "private";
              val = config.services.emile.libvirtnix.secret.private;
            }
          ];
          children = [
            (mkTag {
              name = "description";
              value = "Super secret description";
            })
            (mkTag {
              name = "uuid";
              value = "0a81f5b2-8403-7b23-c8d6-21ccc2f80d6f";
            })
            (mkTag {
              name = "usage";
              args = [
                {
                  key = "type";
                  val = "volume";
                }
              ];
              children = [
                (mkTag {
                  name = "volume";
                  value = "/var/lib/libvirt/images/kernel.img";
                })
              ];
            })
          ];
        };

      in
      {
        # output = pkgs.writeText "libvirt-secret-config.xml" secret;
      };
  };
}
