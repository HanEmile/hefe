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

	# oidc not working and I can't bother to continue debugging it now
	# 
	# Apr 12 15:37:38 corrino authelia[3693799]: {"level":"error","method":"POST","msg":"Access Request failed with error: Client authentication failed (e.g., unknown client, no client authentication included, or unsupported authentication method). The request was determined to be using 'token_endpoint_auth_method' method 'none', however the OAuth 2.0 client registration does not allow this method. The registered client with id 'miniflux' is configured to only support 'token_endpoint_auth_method' method 'client_secret_basic'. Either the Authorization Server client registration will need to have the 'token_endpoint_auth_method' updated to 'none' or the Relying Party will need to be configured to use 'client_secret_basic'.
	#
  # age.secrets.miniflux_oidc_client_secret.owner = "authelia-main";
  # age.secrets.miniflux_oidc_client_secret.group = "authelia-main";
	# 
  # auth via authelia
  # services.authelia.instances.main.settings.identity_providers.oidc.clients = [
  #   {
  #     client_id = "miniflux";

  #     # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
	#     client_secret = "{{ secret \"${config.age.secrets.miniflux_oidc_client_secret.path}\" }}";
  #     public = false;
  #     authorization_policy = "two_factor";
  #     redirect_uris = [ "https://miniflux.emile.space/oauth2/oidc/callback" ];
  #     scopes = [
  #       "openid"
  #       "email"
  #       "profile"
  #     ];
  #     # grant_types = [
  #     #   "refresh_token"
  #     #   "authorization_code"
  #     # ];
  #     # response_types = [ "code" ];
  #     # response_modes = [
  #     #   "form_post"
  #     #   "query"
  #     #   "fragment"
  #     # ];
  #     # token_endpoint_auth_method = "client_secret_post";
  #     # token_endpoint_auth_method = "none";
  #   }
  # ];

	services.miniflux = {
		enable = true;
		package = pkgs.miniflux;
		config = {
		  LISTEN_ADDR = "[::1]:${toString config.emile.ports.miniflux}";
			BASE_URL = "https://miniflux.emile.space";

			# Cleanup job frequency to remove old sessions and archive entries.
		  CLEANUP_FREQUENCY = 48;

			# Set to 1 to enable maintenance mode. Maintenance mode disables the web ui and show a text message to the users.
			# MAINTENANCE_MODE = 1;
			# MAINTENANCE_MESSAGE = "updating foo";
			
			# DISABLE_LOCAL_AUTH = "true";
			# OAUTH2_CLIENT_ID = "miniflux";
			# OAUTH2_USER_CREATION = 1;
			# OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux_oidc_secret.path;
			# OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.emile.space";
			# OAUTH2_OIDC_PROVIDER_NAME = "authelia";
			# OAUTH2_PROVIDER = "oidc";
			# OAUTH2_REDIRECT_URL = "https://miniflux.emile.space/oauth2/oidc/callback";
			
			LOG_LEVEL = "debug";
		};
		createDatabaseLocally = true;

		# File containing the ADMIN_USERNAME and ADMIN_PASSWORD (length >= 6) in the format of an EnvironmentFile=, as described by systemd.exec(5).
		adminCredentialsFile = config.age.secrets.miniflux_admin_file.path;
	};
}
