{ pkgs ? import <nixpkgs> {}, lib, fetchFromGitHub }:

let
  python = pkgs.python311.withPackages ( ps: with ps; [ requests ] );
in pkgs.stdenv.mkDerivation rec {
  name = "glibc-all-in-one";
  version = "master";

  src = fetchFromGitHub {
    owner = "fr0ster";
    repo = "glibc-all-in-one";
    rev = version;
    sha256 = "sha256-vrh/ol56sNWTjGbwZ1Jrh+Lxz7aROvI6IbkJf/WliNE=";
  };

  buildPhase = '''';

  installPhase = ''
    mkdir -p $out/bin
    cp build download extract $out/bin
    cp update_list $out/bin/update_list_raw

    echo "${python}/bin/python3 $out/bin/update_list_raw" > $out/bin/update_list
    chmod +x $out/bin/update_list

    mkdir -p $out/debs
    mkdir -p $out/libs
  '';

  meta = {
    description = "";
    homepage = "https://github.com/fr0ster/glibc-all-in-one";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hanemile ];
  };
 }
