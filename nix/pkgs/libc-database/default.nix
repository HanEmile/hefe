{
  pkgs ? import <nixpkgs> { },
  lib,
  fetchFromGitHub,
  ...
}:

pkgs.stdenv.mkDerivation rec {
  name = "libc-database-${version}";
  version = "master";

  src = fetchFromGitHub {
    owner = "niklasb";
    repo = "libc-database";
    rev = version;
    sha256 = "sha256-Zysjhr76TenMarnoKo+M8DrTNbsnaXSoFZO1puPVoxU=";
  };

  # not building, we just want to download the repo
  buildPhase = '''';
  
  installPhase = ''
		mkdir -p $out/bin
		ls -l
		cp add download dump find get identify $out/bin/
  '';

  meta = {
    description = "Build a database of libc offsets to simplify exploitation";
    homepage = "https://github.com/niklasb/libc-database";
    licenses = lib.license.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
}
