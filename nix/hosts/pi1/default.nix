# build the sd image for the pi using
# ; nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config='./default.nix'

{ lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix>
  ];

  users.users = {
    root = {
      isNormalUser = true;
      home = "/root";
      hashedPassword = "$y$j9T$gs6PF0Ts247/grRimfCP3.$eKq2l72lLeOrVkCSn.jf1niItuBowtf.QYaLbIHX/C0";
    };
  };

  nixpkgs = {
    crossSystem = lib.systems.examples.raspberryPi;
    localSystem = { system = "x86_64-linux"; };
    overlays = [
      (final: super: {
        # Due to https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
  system.stateVersion = "24.05";
}

