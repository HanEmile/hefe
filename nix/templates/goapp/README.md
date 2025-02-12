# goapp

A template for a go app.

```bash
; nix flake show
warning: Git tree '/Users/emile/hefe' is dirty
git+file:///Users/emile/hefe?dir=nix/templates/goapp
├───devShells
│   ├───aarch64-darwin
│   │   └───default: development environment 'nix-shell'
│   ├───aarch64-linux
│   │   └───default omitted (use '--all-systems' to show)
│   ├───x86_64-darwin
│   │   └───default omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       └───default omitted (use '--all-systems' to show)
└───packages
    ├───aarch64-darwin
    │   ├───backend: package 'backend-0.0.1'
    │   ├───backend-docker: package 'docker-image-backend.tar.gz'
    │   ├───frontend: package 'frontend-0.0.1'
    │   └───frontend-docker: package 'docker-image-frontend.tar.gz'
    ├───aarch64-linux
    │   ├───backend omitted (use '--all-systems' to show)
    │   ├───backend-docker omitted (use '--all-systems' to show)
    │   ├───frontend omitted (use '--all-systems' to show)
    │   └───frontend-docker omitted (use '--all-systems' to show)
    ├───x86_64-darwin
    │   ├───backend omitted (use '--all-systems' to show)
    │   ├───backend-docker omitted (use '--all-systems' to show)
    │   ├───frontend omitted (use '--all-systems' to show)
    │   └───frontend-docker omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───backend omitted (use '--all-systems' to show)
        ├───backend-docker omitted (use '--all-systems' to show)
        ├───frontend omitted (use '--all-systems' to show)
        └───frontend-docker omitted (use '--all-systems' to show)
```
