{ self, agenix, nixpkgs, nixpkgs-unstable, deploy-rs, home-manager, darwin, ... }@inputs:

rec {
	generateSystem = name: {
		hostname ? name,
		username ? "emile",
		system ? "x86_64-linux",
		deployUser ? "root",
		homeManagerEnable ? false,
		group ? null,
		modules ? [],
		...
	}:
	let

		# inputs.nixpkgs-${name}, if that doesn't exist, just use nixpkgs
		localNixpkgs =
			nixpkgs.lib.attrByPath
				[ "nixpkgs-${name}" ] # path
				nixpkgs # default
				inputs; # base

		# determine if our system type that is used further down
		systemType =
			if system == "x86_64-linux" then localNixpkgs.lib.nixosSystem
			else
				if system == "aarch64-darwin" then darwin.lib.darwinSystem
				else null;
		
	in systemType { # this may fail if we aren't using x86_64-linux or aarch64-darwin
		inherit system;

		# ; nix repl
		# nix-repl> :lf .
		# nix-repl> nixosConfigurations.corrino._module.args.modules

		modules = modules ++ [

			# a module so that we can access the flake output from inside the
			# flake (yes, I need this for fetching the system type while building the hosts for deploy-rs)
			{ config._module.args = { flake = self; }; }

			# overlays
			({ ... }: {
				nixpkgs.overlays = [
					self.overlays.emile
					(_: _: { inherit (agenix.packages."x86_64-linux") agenix; })
					(_: _: {
						unstable = import nixpkgs-unstable {
							system = "x86_64-linux";
							config.allowUnfree = true;
						};
					})
				];
			})

			# general modules
			agenix.nixosModules.default

			# # the host config itself
			(../hosts +
				(if (system == "x86_64-linux")
				 then "/${name}/configuration.nix"
				 else
					if (system == "aarch64-darwin")
					then "/${name}/darwin-configuration.nix"
					else ""))

			# secrets (have to be added to git (crypted) #lessonslearned)
			({ lib ? (import <nixpkgs/lib>), ... }: let
				secretsPath = (../hosts + "/${name}/secrets");
			in {
				age.secrets = lib.mapAttrs'
					(filename: _:
						lib.nameValuePair (lib.removeSuffix ".age" filename)
						{ file = secretsPath + "/${filename}"; }
					)
					(lib.filterAttrs
						(name: type:
							(type == "regular") &&
							(lib.hasSuffix ".age" name) )
						(if builtins.pathExists secretsPath
						 then builtins.readDir secretsPath
						 else {} )
					);
			})
		]
		
		++ (if (system == "aarch64-darwin")
			then [ (home-manager.darwinModules.home-manager) ]
			else [])
			
		++ (if (homeManagerEnable == true)
			then [{
				home-manager = {
					useGlobalPkgs = true;
					users."${username}" =
						import (../hosts + "/${hostname}/home_${username}.nix");
				};
			}]
			else []);
	};

	mapToNixosConfigurations = { system ? "x86_64-linux", ... }@hosts:
		builtins.mapAttrs
		(name: host: generateSystem name host)
		(nixpkgs.lib.filterAttrs
			(n: v: v.system or "" == "x86_64-linux") hosts);

	mapToDarwinConfigurations = hosts:
		builtins.mapAttrs
		(name: host: generateSystem name host)
		(nixpkgs.lib.filterAttrs
			(n: v: v.system or "" == "aarch64-darwin") hosts);

	generateDeployRsHost = name: {
		hostname ? name,
		ip ? "${name}.pinto-pike.ts.net",
		sshUser ? "root",
		system ? "x86_64-linux",
		...
	}: {
		reboteBuild = true;
		hostname = "${ip}";
		fastConnection = true;
		profiles.system = {
			user = "root"; # user to install as
			sshUser = sshUser; # user to ssh to as

			# make sure people can use sudo 
			# sshOpts = ["-A", "-t", "-S"];

			# make sure to add the nix foo on the darwin hosts to ~/.zshenv
			# as the ~/.zshrc doesn't get sourced when ssh-ing into the system

			path = (if system == "x86_64-linux"
				 then deploy-rs.lib.x86_64-linux.activate.nixos
					self.nixosConfigurations."${name}"
				 else
					if system == "aarch64-darwin"
					then deploy-rs.lib.aarch64-darwin.activate.darwin
						self.darwinConfigurations."${name}"
					else "");
		};
	};

	mapToDeployRsConfiguration = hosts:
		builtins.mapAttrs (name: host: generateDeployRsHost name host) hosts;
	
	buildHosts = hosts:
		builtins.mapAttrs (name: host: host.config.system.build.toplevel)

		# don't build hosts that start with an underscore
		(nixpkgs.lib.filterAttrs
			(name: host: (builtins.substring 0 1 name) != "_")
			hosts
		);
}
