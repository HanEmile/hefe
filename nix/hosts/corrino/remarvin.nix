{ config, ... }:

{
  # deploy:
  # - push code
  # - build in order to get the new hash (nix build .#remarvin)
  # - update hash in the package (//nix/pkgs/remarvin/default.nix)
  # - deploy

  services.emile.remarvin = {
    enable = true;

    username = "marvin_test1";
    homeserver = "matrix.org";
    accesstokenpath = config.age.secrets.remarvin_accesstoken.path;
  };
}
