# original:
# https://git.clerie.de/clerie/nixfiles/src/branch/master/lib/default.nix

inputs:

let
	callLibs = file: import file ({
		inherit lib inputs;
	} // inputs);

	lib = {
		flake-helper = callLibs ./flake-helper.nix;
		inherit ("flake-helper")
			generateSystem
			mapToNixosConfigurations
			mapToDarwinConfigurations
			generateDeployRsHost
			mapToDeployRsConfiguration
			buildHosts;
	};
in
	lib
