{
  inputs.nixpkgs.url = "git+https://github.com/nixos/nixpkgs.git?shallow=1?ref=nixos-24.11";
  inputs.flake-utils.url = "git+https://github.com/numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
        };

        package-and-docker = name: (let
          pkgname = name + "-pkg";
          dockername = name + "-docker";

          package = import ./${name} { inherit pkgs name; };
        in {
          # the raw package
          ${pkgname} = package;

          # the docker image
          ${dockername} = pkgs.dockerTools.buildImage {
            name = "${name}";
            config.Cmd = [ "${package}/bin/${name}" ];
          };
        });
      in
      {
        packages = { }
                   // (package-and-docker "backend")
                   // (package-and-docker "frontend");

        devShells.default = pkgs.mkShell {
          buildInputs = builtins.attrValues {
            inherit (pkgs)
              go
              gopls
              helix
              ripgrep
              fd
              tokei
              tree
              eza
              ;
          };

          shellHook = ''
            alias ls=eza
            echo "goapp shell"
            export PS1='>; '
          '';
        };
      }
    );
}
