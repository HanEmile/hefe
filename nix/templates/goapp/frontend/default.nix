{ pkgs, packagename, ... }:

let
	version = "0.0.1";
in
pkgs.buildGoModule {
	name = "${packagename}-${version}";
	pname = "${packagename}";
	version = "${version}";

	src = ./.;
  subPackages = [ "src" ];
	vendorHash = "sha256-8wYERVt3PIsKkarkwPu8Zy/Sdx43P6g2lz2xRfvTZ2E=";

	postInstall = ''
		mkdir -p $out
		mv $out/bin/src $out/bin/${packagename}
	'';

	doCheck = true;
}
