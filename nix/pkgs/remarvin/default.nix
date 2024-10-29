{
  pkgs,
  lib,
  fetchgit,
}:

pkgs.buildGoModule rec {
  name = "remarvin-${version}";
  version = "0.1.1";

  src = fetchgit {
    url = "git://git.emile.space/remarvin.git";
    hash = "sha256-jgV5bzQQ4n9v7PgFQ5n0yFTPcjgHNQ/BYPxzTp1Os4w=";
  };

  vendorHash = null;
  CGO_ENABLED = 0;
  subPackages = [ "src" ];

  postInstall = ''
    mkdir -p $out
    mv $out/bin/src $out/bin/remarvin
  '';

  doCheck = false;

  meta = {
    description = "A small marvin bot";
    homepage = src.url;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
}
