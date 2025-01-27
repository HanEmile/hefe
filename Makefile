.PHONY: help

help:
	@echo "build - build toplevel into `./result`"
	@echo "update - updates and commit changes"
	@echo "deploy - deploys to the server"
	@echo "check - run local checks"
	@echo "dry-activate - build and show different"

corrino:
	deploy .#corrino --skip-checks -- --show-trace -L

build:
	nix run nixpkgs#nix-output-monitor build ".#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel"

update:
	nix flake update --commit-lock-file

switch-caladan:
	nix run https://github.com/LnL7/nix-darwin/archive/master.tar.gz -- switch --flake .#caladan

build-corrino:
	nix run nixpkgs#nix-output-monitor build .#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel

deploy: build
	nix run -- nixpkgs#nixos-rebuild switch \
		--fast \
		--build-host root@${BUILDHOST} \
		--target-host root@${HOSTNAME} \
		--flake ".#${HOSTNAME}"

check:
	nix flake check

dry-activate:
	nix run -- nixpkgs#nixos-rebuild dry-activate --target-host root@${HOSTNAME} --flake ".#corrino" 

