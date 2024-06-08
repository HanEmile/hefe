# # export NIX_PATH=nixpkgs=/home/jane/local_nixpkgs_checkout
# nix-build --cores 0 '<nixpkgs/nixos>' \
#   -I nixos-config=configuration.nix \
#   -A config.system.build.sdImage \
#   -o result-cross \
#   --keep-going

nix-build \
	--cores 0 \
	'<nixpkgs/nixos>' \
	-I nixos-config=configuration.nix \
	-A config.system.build.sdImage \
	-o result-cross \
	--show-trace
