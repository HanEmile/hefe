{
  description = ''
    One Flake to rule them all^W^Wcommon CTF problems, namely broken infa.

    Usage:
    ; nix flake init -t git+https://github.com/hanemile/hefe\#ctf
  '';
  nixConfig.bash-prompt = "\[ctf\]; ";

  inputs = {
    nixpkgs.url = "git+ssh://git@github.com/nixos/nixpkgs.git?shallow=1&ref=nixos-24.11";
    pwndbg.url = "git+ssh://git@github.com/pwndbg/pwndbg";
  };

  # Flake outputs
  outputs =
    { nixpkgs, pwndbg, ... }@inputs:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = f: genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        pwndbg = inputs.pwndbg.packages.${system}.default;
      });
    in
    {
      # Development environment output
      devShells = forAllSystems (
        { pkgs, pwndbg }:
        {
          default =
            pkgs.mkShell {
              shellHook = ''
                cat << EOF > solve.py
                from pwn import *

                context.gdbinit="${pwndbg}/share/pwndbg/gdbinit.py"

                # exe = ELF("./a.out")

                p = remote("138.199.213.51", 31335)
                #p = gdb.debug(exe.path, gdbscript=''''
                #                break main
                #                c
                #              '''')

                p.sendlineafter(b"> ", b"asd")

                p.interactive()
                EOF
              '';
              packages = [
                  pkgs.gcc
                  pwndbg
                  (pkgs.python311.withPackages ( ps: with ps; [
                    pwntools
                    pwndbg
                    pycryptodome
                  ]))
              ];
            };
        }
      );
    };
}
