{ ... }:

{
  nixpkgs = {
    overlays = [
      (self: super: {
        # helix-2303 = self.callPackage ../../pkgs/helix-2303 { };
        # r2 = self.callPackage ../../pkgs/radare2-5.8.4 { };
        # ansel = self.callPackage ../../pkgs/ansel { };
        # typst = self.callPackage ../pkgs/radare2-5.8.4 { };
      })
    ];
    config = {
      allowUnfree = true;
      allowBroken= true;
    };
  };
}
