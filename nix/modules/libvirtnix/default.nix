{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.emile.libvirtnix;
in
{
  options.services.emile.libvirtnix = with lib; {
    enable = mkEnableOption "enable libvirtnix";
    instances = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "enable this instance";
              domain = mkOption {
                type = types.submodule (import ./domain.nix);
              };
            };
          }
        )
      );
      default = { };
      description = ''
        A full libvirt config, statically defined using nix.
      '';
      example = ''
        {
          domain = {
            name = "vm";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (
      name: guest:
      lib.nameValuePair "libvirtd-guest-${name}" {
        after = [ "libvirtd.service" ];
        requires = [ "libvirtd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
        script =
          let
            xml =
              pkgs.writeText "libvirt-guest-${name}.xml" ''<domain ''
              + (lib.optionalString (guest.domain.type != "") "type='${guest.domain.type}' ")
              + (lib.optionalString (guest.domain.id != 0) "id='${guest.domain.type}'")
              + ''>''
              + (lib.optionalString (guest.domain.name != "") "<name>${guest.domain.name}</name>")
              + (lib.optionalString (guest.domain.name != "") "<name>${guest.domain.name}</name>")
              + (lib.optionalString (guest.domain.uuid != "") "<uuid>${guest.domain.uuid}</uuid>")
              + (lib.optionalString (guest.domain.genid != "") "<genid>${guest.domain.genid}</genid>")
              + (lib.optionalString (guest.domain.title != "") "<title>${guest.domain.title}</title>")
              + (lib.optionalString (
                guest.domain.description != ""
              ) "<description>${guest.domain.description}</description>")
              + (lib.optionalString (guest.domain.metadata != "") "${guest.domain.metadata}")
              + ''
                  <os>
                    <type>hvm</type>
                  </os>
                  <memory unit="GiB">${toString guest.domain.memory}</memory>
                  <devices>
                    <disk type="volume">
                      <source volume="guest-${name}"/>
                      <target dev="vda" bus="virtio"/>
                    </disk>
                    <graphics type="spice" autoport="yes"/>
                    <input type="keyboard" bus="usb"/>
                  </devices>
                  <features>
                    <acpi/>
                  </features>
                </domain>
              '';
          in
          ''
            uuid="$(${pkgs.libvirt}/bin/virsh domuuid '${name}' || true)"
            ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
            ${pkgs.libvirt}/bin/virsh start '${name}'
          '';
        preStop = ''
          ${pkgs.libvirt}/bin/virsh shutdown '${name}'
          let "timeout = $(date +%s) + 10"
          while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^${name}$')" -gt 0 ]; do
            if [ "$(date +%s)" -ge "$timeout" ]; then
              # Meh, we warned it...
              ${pkgs.libvirt}/bin/virsh destroy '${name}'
            else
              # The machine is still running, let's give it some time to shut down
              sleep 0.5
            fi
          done
        '';
      }
    ) config.services.emile.libvirtnix.instances;
  };
}
