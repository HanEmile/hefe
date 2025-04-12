{ config, pkgs, ... }:

{
	services.nginx.virtualHosts."miniflux.emile.space" = {
		forceSSL = true;
		enableACME = true;
		locations = {
			"/" = {
				proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
			};
		};
	};

  # auth via authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      id = "miniflux";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      secret = "$pbkdf2-sha512$310000$rlOuqUDGc/kl3bw7JgcSpg$4COyNudsu/7L8qhnxfcQld5Fy.ru/JUp7RCI7dCHZMtzxRnhckW8A7uz3Xeuc7.BjCIwc4GdWusPt6.TiH6Kpw";
      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [ "https://miniflux.emile.space/oauth2/oidc/callback" ];
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      grant_types = [
        "refresh_token"
        "authorization_code"
      ];
      response_types = [ "code" ];
      response_modes = [
        "form_post"
        "query"
        "fragment"
      ];
      token_endpoint_auth_method = "client_secret_post";
    }
  ];

	services.miniflux = {
		enable = true;
		package = pkgs.miniflux;
		config = {
			BASE_URL = "https://miniflux.emile.space";

			# Cleanup job frequency to remove old sessions and archive entries.
		  CLEANUP_FREQUENCY = 48;

			# Set to 1 to enable maintenance mode. Maintenance mode disables the web ui and show a text message to the users.
			# MAINTENANCE_MODE = 1;
			# MAINTENANCE_MESSAGE = "updating foo";
			
			OAUTH2_CLIENT_ID = "miniflux";
			OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux_oidc_secret.path;
			OAUTH2_OIDC_DISCOVERY_ENDPOINT = "sso.emile.space";
			OAUTH2_OIDC_PROVIDER_NAME = "authelia";
			OAUTH2_PROVIDER = "oidc";
			OAUTH2_REDIRECT_URL = "https://miniflux.emile.space/oauth2/oidc/callback";
			
		  LISTEN_ADDR = "[::1]:${toString config.emile.ports.miniflux}";
		};
		createDatabaseLocally = true;

		# File containing the ADMIN_USERNAME and ADMIN_PASSWORD (length >= 6) in the format of an EnvironmentFile=, as described by systemd.exec(5).
		adminCredentialsFile = config.age.secrets.miniflux_admin_file.path;
	};
	


}
