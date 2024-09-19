{ ... }:
let
  release = "nixos-23.05";
in
{
  imports = [
    (builtins.fetchTarball {
      # Pick a commit from the branch you are interested in
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
      # And set its hash
      sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.emile.space";
    domains = [ "emile.space" ];

    # A list of all login accounts. To create the password hashes, use
    # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
      "mail@emile.space" = {
        hashedPasswordFile = "/etc/nixos/keys/mail";
        aliases = [ "@emile.space" ];
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

    # as well with ssl
    enableImapSsl = true;
    enablePop3Ssl = true;
    enableSubmissionSsl = true;

    enableManageSieve = true;

    virusScanning = false;

  };
}
