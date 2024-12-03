{
  pkgs,
  lib,
  fetchgit,
}:

pkgs.buildGoModule rec {
  name = "r2wars-web-${version}";
  version = "0.1.2";

  src = fetchgit {
    url = "git://github.com/hanemile/r2wars-web.git";
    hash = "sha256-/LOjnCnns7nIV25aKUFCNoE3sZrZ72lvWSBlD4zuHQc=";
  };

  vendorHash = null;

  CGO_ENABLED = 0;
  subPackages = [ "src" ];

  # postInstall = ''
  #   mkdir -p $out
  #   cp -r templates $out
  #   mv $out/bin/src $out/bin/r2wars-web
  # '';

  doCheck = false;

  meta = {
    description = "A golang implementation of r2wars";
    homepage = "https://r2wa.rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
}
