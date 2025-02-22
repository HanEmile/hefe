{ pkgs, name, ... }:

let
  version = "0.0.1";
in
pkgs.buildGoModule {
  pname = "${name}";
  version = "${version}";

  src = ./.;

  # use the dependencies directly from the vendor/ folder
  # vendorHash = null;
   
  vendorHash = "sha256-dXWwAP0XM24cAcDV87XHQX9dLg6TDQ7ZVfEFgW/Q+J4=";

  doCheck = false;

  postInstall = ''
    cp -r templates $out
    mv $out/bin/{src,${name}}
  '';
}
