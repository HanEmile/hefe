{ lib, pkgs, config, ... }:

let
  cfg = config.services.gitea;
in {
  services.nginx.virtualHosts."git.emile.space" = {
    forceSSL = true;
    enableACME = true;

    # TODO(emile): figure out why this doesn't work when enabled, has to do with authelia
    # extraConfig = authelia-location;

    locations = {
      "/" = {
        # proxyPass = "http://127.0.0.1:3000";
        proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";

        # TODO(emile): figure out why this doesn't work when enabled, has to do with authelia
        # extraConfig = authelia-authrequest;
      };
    };
  };

	# auth via authelia
	services.authelia.instances.main.settings.identity_providers.oidc.clients = [
  	{
  		id = "git";

  		# ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
  		secret = "$pbkdf2-sha512$310000$4bi9wRkfcqnjbdmgt7rU.g$pQ2mC6GW4.BQwanGKKFhFyIx6Y.WY80xd/YpmlYOPnlnGBWpp0dSOTv6a/2yqSA5D.EuRkGCyeexSE5FdCK2TA";
  		public = false;
  		authorization_policy = "two_factor";
  		redirect_uris = [
  			"https://git.emile.space/user/oauth2/authelia/callback"
  		];
  		scopes = [
  			"openid"
  			"email"
  			"profile"
  		];
  	}
  ];

  services.gitea = rec {
    enable = true;

    appName = "git.emile.space";

    # unstable in order to use the 1.20... version
    #package = pkgs.forgejo;
    package = pkgs.unstable.forgejo;

    stateDir = "/var/lib/gitea";
    repositoryRoot = "${stateDir}/repositories";

    settings = {
      service.DISABLE_REGISTRATION = true;

      DEFAULT = {
        WORK_PATH = "/var/lib/gitea";
      };

      server = {
        DOMAIN = pkgs.lib.mkForce "git.emile.space";
        ROOT_URL = pkgs.lib.mkForce "https://git.emile.space";
        HTTP_PORT = config.emile.ports.git;

        #START_SSH_SERVER = true;
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_USER = "gitea";
        SSH_DOMAIN = "git.emile.space";

        REPO_INDEXER_ENABLED = true;
      };

      indexer = {
        REPO_INDEXER_ENABLED = true;
        ISSUE_INDEXER_PATH = "${stateDir}/indexers/issues.bleve";
        REPO_INDEXER_PATH = "${stateDir}/indexers/repos.bleve";
        MAX_FILE_SIZE = 1048576;
        REPO_INDEXER_INCLUDE = "";
        REPO_INDEXER_EXCLUDE = "resources/bin/**";
      };

      #federation = {
      #  enable = true;
      #  share_user_statistics = true;
      #  max_size = 4;
      #};
    };
  };

  users.users.git = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "git";
    extraGroups = [ "gitea" ];
    home = cfg.stateDir;
    uid = 127;
  };
  users.groups.git = { };
}
