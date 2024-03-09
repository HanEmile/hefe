{ pkgs, config, ... }:

let
  cfg = config.services.gitea;
in {
  services.nginx.virtualHosts."git.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };

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
  };
  users.groups.git = { };
}
