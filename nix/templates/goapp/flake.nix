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

        # take a name and return an attrset with a corresponding package and docker container
        package-and-docker = name: (let
          # define the name for the package and docker container
          pkgname = name;
          dockername = name + "-docker";

          # import the package itself
          package = import ./${name} { inherit pkgs name; };

          # define the container
          container = pkgs.dockerTools.buildImage {
            name = "${name}"; # TODO(emile): this could simply be `inherit name;` iinw
            config.Cmd = [ "${package}/bin/${name}" ];
          };
        in {
          # the raw package
          ${pkgname} = package;

          # the docker image
          ${dockername} = container;
        });
      in
      {
        packages = { }
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
