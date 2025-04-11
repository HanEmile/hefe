{ pkgs ? import <nixpkgs> {}, lib, fetchFromGitHub }:

pkgs.stdenv.mkDerivation rec {
  name = "glibc-all-in-one";
  version = "master";

  src = fetchFromGitHub {
    owner = "fr0ster";
    repo = "glibc-all-in-one";
    rev = version;
    sha256 = "Zysjhr76TenMarnoKo+M8DrTNbsnaXSoFZO1puPVoxU=";
  };

  buildPhase = '''';

  installPhase = ''
  '';

  meta = {
    description = "";
    homepage = "https://github.com/fr0ster/glibc-all-in-one";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
 }
