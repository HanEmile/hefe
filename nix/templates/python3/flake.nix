{
	description = "a simple flake for using python with some dependencies";
	nixConfig.bash-promt = "py; ";

	inputs = {
    nixpkgs.url = "git+https://github.com/nixos/nixpkgs?ref=release-23.11";
	};
	
	outputs = { nixpkgs, ... }:
	
	let
		pkgs = import nixpkgs {
			system = "aarch64-darwin";
		};
	in {
		devShells."aarch64-darwin".default =
			let
				python = pkgs.python311;
			in
				pkgs.mkShell {
			  packages = [
			    (python.withPackages (ps: with ps; [
						pwntools
						beautifulsoup4
						requests
			    ]))
			  ];
			};
	};
}

