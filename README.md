# hefe

## Secrets

- Managed using agenix
- Don't forget to add secrets to git!
- Edit secrets such as below

```bash
; EDITOR=hx nix run git+https://github.com/ryantm/agenix -- -e nix/hosts/corrino/secrets/pretix.age
```

## Deploy

Using [deploy-rs](https://github.com/serokell/deploy-rs) to deploy

```bash
; deploy .#corrino
; deploy .#caladan
```

