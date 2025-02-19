{ pkgs, name, ... }:

let
  version = "0.0.1";
in
pkgs.buildGoModule {
  name = "${name}-${version}";
  pname = "${name}";
  version = "${version}";

  src = ./.;
  subPackages = [ "src" ];
  vendorHash = "sha256-VXuhsXejduIcthawj4qu7hruBEDegj27YY0ym5srMQY=";

  doCheck = true;
}
