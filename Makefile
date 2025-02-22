.PHONY: help

help:
	@echo "build - build toplevel into `./result`"
	@echo "update - updates and commit changes"
	@echo "deploy - deploys to the server"
	@echo "check - run local checks"
	@echo "dry-activate - build and show different"

corrino:
	time deploy .#corrino --skip-checks -- --show-trace -L

build:
	time nix run nixpkgs#nix-output-monitor build ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel"

update:
	time nix flake update --commit-lock-file

switch-caladan:
	time nix run https://github.com/LnL7/nix-darwin/archive/master.tar.gz -- switch --flake .#caladan

build-corrino:
	time nix run nixpkgs#nix-output-monitor build .#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel

deploy: # build
	time nix run -- nixpkgs#nixos-rebuild switch \
		-vvv \
		--fast \
		--build-host root@${BUILDHOST} \
		--target-host root@${HOSTNAME} \
		--flake ".#${HOSTNAME}"

check:
	time nix flake check

dry-activate:
	time nix run -- nixpkgs#nixos-rebuild dry-activate --target-host root@${HOSTNAME} --flake ".#corrino" 

