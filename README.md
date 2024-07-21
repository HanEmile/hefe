# hefe

## Secrets

- Managed using agenix
- Don't forget to add secrets to git!

Create secrets:
```bash
./secret_create.sh [host] [name of secret ending in .age]
```

Edit secrets:

```bash
; EDITOR=hx nix run git+https://github.com/ryantm/agenix -- -e <secret>
```

Print the generated secrets file as follows:

```bash
; nix eval -I nixpkgs=flake:nixpkgs --file secrets.nix
```

## Deploy

Using [deploy-rs](https://github.com/serokell/deploy-rs) to deploy

```bash
; deploy .#corrino
; deploy .#caladan
; deploy .#lampadas
; deploy .#lernaeus
```

