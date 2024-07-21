# build the sd image for the pi using
# ; nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config='./default.nix'

# after booting
# ; nix-channel --list
# ; nix-channel --remove nixos
# ; nix-channel --add https://channels.nixos.org/nixos-unstable nixos
# ; nix-channel --update nixos
# (this takes quite some time)
# ; nixos-rebuild switch

{ lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix>
  ];

  users.users = {
    emile = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$gKt6Iovrn.SAkMxnTCqqV1$55.sKRrjWTbe7Z6Xi17G0e3G7GbAGc65YXtX9zD5AR3";
      extraGroups = [ "wheel" ];
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

