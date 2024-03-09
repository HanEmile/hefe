{ pkgs ? import <nixpkgs> {} }:

let
a = name:
	let
		secretsPath = ../hosts + "/${name}/secrets";
	in {
		age.secrets = pkgs.lib.mapAttrs'
			(filename: _:
				pkgs.lib.nameValuePair (pkgs.lib.removeSuffix ".age" filename)
				{
					file = secretsPath + "/${filename}";
				}
			)
			(pkgs.lib.filterAttrs
				(name: type:
					(type == "regular") &&
					(pkgs.lib.hasSuffix ".age" name) )
				(if builtins.pathExists secretsPath
				 then builtins.readDir secretsPath
				 else {} )
			);
	};
in
{ b = a "corrino"; }
