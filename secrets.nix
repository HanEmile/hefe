# { pkgs ? import <nixpkgs> {} }:

# taken from
# https://git.clerie.de/clerie/nixfiles/src/branch/master/secrets.nix

# nix eval --impure --expr 'import ./secrets.nix'

let
	pubkeysFor = directory:
		let
			instances = builtins.attrNames (builtins.readDir directory);
			instancesWithPubkey = builtins.filter (i: builtins.pathExists (directory + "/${i}/ssh.pub")) instances; 
		in
			builtins.listToAttrs (
				# map (i: { name = i; value = builtins.readFile (directory + "/${i}/ssh.pub"); }
				map (i: {
					name = i;
					value = (import (directory + "/${i}/")).sshKey;
				}
			) instancesWithPubkey);

	hosts = pubkeysFor ./nix/hosts;
	users = pubkeysFor ./nix/users;

	secretsForHost = hostname: let

		secretFiles = builtins.attrNames
			(builtins.readDir (./nix/hosts + "/${hostname}/secrets"));
	
		listOfSecrets = builtins.filter (i:
			(builtins.stringLength i) > 4
			&& builtins.substring ((builtins.stringLength i) - 4)
				(builtins.stringLength i) i == ".age"
		) secretFiles;

	in
		if
			builtins.pathExists (./nix/hosts + "/${hostname}/secrets")
			&& builtins.pathExists (./nix/hosts + "/${hostname}/ssh.pub")
		then
			map
				(secret: {
					name = "nix/hosts/${hostname}/secrets/${secret}";
					value = {
						publicKeys = [
							users.emile
							hosts."${hostname}"
						];
					};
				})
				(listOfSecrets ++ [ "new" ])
		else
			[];
in
	builtins.listToAttrs (
		builtins.concatMap
			(hostname: secretsForHost hostname)
			(builtins.attrNames (builtins.readDir ./nix/hosts))
	)
