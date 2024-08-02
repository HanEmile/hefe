{ lib, ... }: 

with lib; {
  options.emile.ports = mkOption {
    type = types.anything;
  };
}
