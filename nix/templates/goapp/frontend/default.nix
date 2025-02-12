{ pkgs, name, ... }:

let
  version = "0.0.1";
in
pkgs.buildGoModule {
  name = "${name}-${version}";
  pname = "${name}";
  version = "${version}";

  src = ./.;
  subPackages = [ "" ];
  vendorHash = "sha256-tIk8lmyuVETrOW7fA7K7uNNXAAtJAYSM4uH+xZaMWqc=";

  doCheck = true;
}
