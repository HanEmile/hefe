{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:

pkgs.buildGoModule rec {
  name = "r2wars-web-${version}";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "hanemile";
    repo = "r2wars-web";
    rev = "main";    
    sha256 = "sha256-cKvdMPysrJonoBqxiXWyb8Nn6qr2Zn6eQqyGWRMgmao=";
  };

  vendorHash = null;

  CGO_ENABLED = 0;
  subPackages = [ "src" ];

  postInstall = ''
    mkdir -p $out
    cp -r templates $out
    mv $out/bin/src $out/bin/r2wars-web
  '';

  doCheck = false;

  meta = {
    description = "A golang implementation of r2wars";
    homepage = "https://r2wa.rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
}
