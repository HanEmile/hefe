let
	pkgs = import <nixpkgs> {};
in
	pkgs.lib.evalModules {
		modules = [
			# ./secret.nix
			./domain.nix
			./config.nix
		];
	}
