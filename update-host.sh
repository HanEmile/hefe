HOSTNAME="corrino"

HYDRA=https://hydra.emile.space/job/hefe/builds/nixosConfigurations.${HOSTNAME}/latest-finished
STORE_PATH="$(curl -sL -H "Accept: application/json" "${HYDRA}" | jq -r ".buildoutputs.out.path")"

nix copy --from "https://nix-cache.emile.space" "${STORE_PATH}"
nix-env -p "/nix/var/nix/profiles/system" --set "${STORE_PATH}"
/nix/var/nix/profiles/system/bin/switch-to-configuration boot

