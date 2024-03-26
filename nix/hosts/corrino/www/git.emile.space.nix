{ pkgs, config, ... }:

let
  cfg = config.services.gitea;
  ports = import ../ports.nix;
  authelia-location = ''
    set $upstream_authelia http://127.0.0.1:9091/api/authz/auth-request;

    ## Virtual endpoint created by nginx to forward auth requests.
    location /internal/authelia/authz {
      ## Essential Proxy Configuration
      internal;
      proxy_pass $upstream_authelia;

      ## Headers
      ## The headers starting with X-* are required.
      proxy_set_header X-Original-Method $request_method;
      proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header Content-Length "";
      proxy_set_header Connection "";

      ## Basic Proxy Configuration
      proxy_pass_request_body off;
      proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; # Timeout if the real server is dead
      proxy_redirect http:// $scheme://;
      proxy_http_version 1.1;
      proxy_cache_bypass $cookie_session;
      proxy_no_cache $cookie_session;
      proxy_buffers 4 32k;
      client_body_buffer_size 128k;

      ## Advanced Proxy Configuration
      send_timeout 5m;
      proxy_read_timeout 240;
      proxy_send_timeout 240;
      proxy_connect_timeout 240;
    }
  '';

  authelia-authrequest = ''
    ## Send a subrequest to Authelia to verify if the user is authenticated and has permission to access the resource.
    auth_request /internal/authelia/authz;

    ## Save the upstream metadata response headers from Authelia to variables.
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;

    ## Inject the metadata response headers from the variables into the request made to the backend.
    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Email $email;
    proxy_set_header Remote-Name $name;

    ## Configure the redirection when the authz failure occurs. Lines starting with 'Modern Method' and 'Legacy Method'
    ## should be commented / uncommented as pairs. The modern method uses the session cookies configuration's authelia_url
    ## value to determine the redirection URL here. It's much simpler and compatible with the mutli-cookie domain easily.

    ## Modern Method: Set the $redirection_url to the Location header of the response to the Authz endpoint.
    auth_request_set $redirection_url $upstream_http_location;

    ## Modern Method: When there is a 401 response code from the authz endpoint redirect to the $redirection_url.
    error_page 401 =302 $redirection_url;

    ## Legacy Method: Set $target_url to the original requested URL.
    ## This requires http_set_misc module, replace 'set_escape_uri' with 'set' if you don't have this module.
    # set_escape_uri $target_url $scheme://$http_host$request_uri;

    ## Legacy Method: When there is a 401 response code from the authz endpoint redirect to the portal with the 'rd'
    ## URL parameter set to $target_url. This requires users update 'auth.example.com/' with their external authelia URL.
    # error_page 401 =302 https://auth.example.com/?rd=$target_url;
  '';
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
        HTTP_PORT = ports.git;

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
