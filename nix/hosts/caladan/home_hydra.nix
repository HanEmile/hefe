{ pkgs, ... }:

{
 home = {
  stateVersion = "22.11";
  username = "hydra";
  homeDirectory = "/Users/hydra";
 };

 programs = {
  # let home-manager install and manage itself
  home-manager.enable = true;
 };

 home.packages = with pkgs; [
  tailscale
 ];

 services.openssh.enable = true;
}
