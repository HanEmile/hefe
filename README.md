# hefe

## Buildhosts

[hydra](https://hydra.emile.space) builds the packages, templates and hosts continously.

- x86_64-linux: corrino (Hetzner AX41)
- x86_64-darwin: kaitain (Mac Mini)
- aarch64-linux: pi4
- aarch64-darwin: caladan (m1 macbook air)

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

```bash
; BUILDHOST=corrino HOSTNAME=corrino make deploy
; BUILDHOST=corrino HOSTNAME=lampadas make deploy
; BUILDHOST=corrino HOSTNAME=lankiveil make deploy
; make switch-caladan
```

## Troubleshooting

Weird `lock` issues? Try `sudo pkill -9 nix-daemon` on the build machine

