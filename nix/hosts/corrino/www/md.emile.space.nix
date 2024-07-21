{ config, pkgs, ... }:

let
	ports = import ../ports.nix;
in {
	services.nginx.virtualHosts."md.emile.space" = {
		forceSSL = true;
		enableACME = true;

		# TODO(emile): figure out why this doesn't work when enabled, has to do with authelia
		# extraConfig = authelia-location;

		locations = {
			"/" = {
				# proxyPass = "http://127.0.0.1:3003";
        proxyPass = "http://127.0.0.1:${toString config.services.hedgedoc.settings.port}";

				# TODO(emile): figure out why this doesn't work when enabled, has to do with authelia
				# extraConfig = authelia-authrequest;
			};
		};
	};

	# auth via authelia
	services.authelia.instances.main.settings.identity_providers.oidc.clients = [
		{
			id = "HedgeDoc";

			# ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
			secret = "$pbkdf2-sha512$310000$l4Kyec7Q9oY2GAhWA/xMig$P/MYFmulfgsDNyyiclUzd6le0oSiOvqCIvl4op5DkXtVTxLWlMA3ZwhJ6Z7u.OfIREuEM2htH6asxWPhBhkpNQ"; 
			public = false;
			authorization_policy = "two_factor";
			redirect_uris = [
				"https://md.emile.space/auth/oauth2/callback"
			];
			scopes = [
				"openid"
				"email"
				"profile"
			];
			grant_types = [
				"refresh_token"
				"authorization_code"
			];
			response_types = [
				"code"
			];
			response_modes = [
				"form_post"
				"query"
				"fragment"
			];
		}
	];

	services.hedgedoc = {
    enable = true;
		package = pkgs.hedgedoc;

		environmentFile = config.age.secrets.hedgedoc_environment_variables.path;

		settings = {
			host = "127.0.0.1";
			port = ports.md;

			domain = "md.emile.space";

			urlPath = null; # we're hosting on the root of the subdomain and not a subpath
			allowGravatar = true;

			# we're terminating tls at the reverse proxy
			useSSL = false;

			# Use https:// for all links.
			# This is useful if you are trying to run hedgedoc behind a reverse proxy.
			# Only applied if domain is set.
			protocolUseSSL = true;

			# don't allow unauthenticated people to just write somewhere
			allowAnonymous = false;
			allowAnonymousEdits = true; # This allows us to set pads "freely"

			defaultPermission = "private";

			db = {
			  dialect = "sqlite";
			  storage = "/var/lib/hedgedoc/db.sqlite";
			};

			uploadsPath = "/var/lib/hedgedoc/uploads";

			path = null; # we want to use HTTP and not UNIX domain sockets...

			allowOrigin = with config.services.hedgedoc.settings; [ host domain ];
		};
  };

	# backups
	services.restic.backups = {
	  storagebox = {
			user = "u331921";
			repository = "stfp:u331921@u331921.your-storagebox-de:23/restic";
			initialize = true; # initializes the repo, don't set if you want manual control
			passwordFile = config.age.secrets.restic_password.path;
			paths = [
				"/var/lib/hedgedoc/"
			];
	  };
	};

}
