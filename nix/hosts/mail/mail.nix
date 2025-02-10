{ config, pkgs, ... }:
let
  #release = "nixos-21.11";
  # release = "nixos-23.05";
  # release = "nixos-24.05";
  release = "nixos-24.11";
in {
  imports = [
    (builtins.fetchTarball {
      # Pick a commit from the branch you are interested in
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      # And set its hash
      #sha256 = "1i56llz037x416bw698v8j6arvv622qc0vsycd20lx3yx8n77n44";
      #sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
      #sha256 = "0000000000000000000000000000000000000000000000000000";
      sha256 = "05k4nj2cqz1c5zgqa0c6b8sp3807ps385qca74fgs6cdc415y3qw";
    })
  ];

  # temporary fix for the issue linked below that showed up after updating to
  # nixos-24.05 and the nixos-24.05 release
  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275
  services.dovecot2.sieve.extensions = [ "fileinto" ];

  mailserver = {
    enable = true;
    fqdn = "mail.emile.space";
    domains = [ "emile.space" ];

    # A list of all login accounts. To create the password hashes, use
    # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
        "mail@emile.space" = {
            hashedPasswordFile = "/etc/nixos/keys/mail";
            aliases = ["@emile.space"];
        };
    };

    localDnsResolver = false;

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    #certificateScheme = 3;
    certificateScheme = "acme-nginx";


    # Enable IMAP and POP3
    enableImap = true;
    enablePop3 = true;
    enableSubmission = true;

    enableImapSsl = true;
    enablePop3Ssl = true;
    enableSubmissionSsl = true;

    enableManageSieve = true;

    virusScanning = false;
  };
}
