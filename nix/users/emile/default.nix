{
  # users.users.emile = {
  #   isNormalUser = true;
  #   extraGroups = [
  #     "wheel"
  #   ];
  #   openssh.authorizedKeys.keys = [
  #     (builtins.readFile ./ssh.pub)
  #   ];
  # };

  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew";
}
