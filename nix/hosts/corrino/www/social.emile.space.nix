{ config, pkgs, ... }:

{

	# the reverse proxy to gotosocial
  services.nginx.virtualHosts."social.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString config.emile.ports.gotosocial}";
				proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 40M;
        '';
      };

    };
  };

	# Redirects from emile.space to social.emile.space
	# Without this, other instances have problems getting from the username
	#   @hanemile@emile.space to the host social.emile.space
	# https://docs.gotosocial.org/en/latest/advanced/host-account-domain/
  services.nginx.virtualHosts."emile.space" = {
    locations = {
		  "/.well-known/webfinger".extraConfig = ''
		    rewrite ^.*$ https://social.emile.space/.well-known/webfinger permanent;
      '';

		  "/.well-known/host-meta".extraConfig = ''
	      rewrite ^.*$ https://social.emile.space/.well-known/host-meta permanent;
			'';

		  "/.well-known/nodeinfo".extraConfig = ''
	      rewrite ^.*$ https://social.emile.space/.well-known/nodeinfo permanent;
			'';
		};
	};


	# auth via authelia
	services.authelia.instances.main.settings.identity_providers.oidc.clients = [
		{
			id = "gotosocial";

			# ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
			secret = "$pbkdf2-sha512$310000$oDpZ5FuO965TbjPoophJXw$dbkAwWFvLN1h1Zh9US2ZOE5ilPRdEHMdGF/x0uorou2UqURrXF0KQmXxsV38F2yYMS7u/ecramKlvfMwsqHOcg"; 
			public = false;
			authorization_policy = "two_factor";
			redirect_uris = [
				"https://social.emile.space/auth/callback"
			];
			scopes = [
				"openid"
				"email"
				"profile"
				"groups"
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
					
	services.gotosocial = {
		enable = true;
		package = pkgs.gotosocial;
		settings = {
			host = "social.emile.space";
			port = config.emile.ports.gotosocial;
			bind-address = "127.0.0.1";
			account-domain = "emile.space";
			db-type = "sqlite";
			db-address = "/var/lib/gotosocial/database.sqlite";
			protocol = "https";
			storage-local-base-path = "/var/lib/gotosocial/storage";
			oidc-idp-name = "authelia";
			oidc-client-id = "gotosocial";
			advanced-rate-limit-requests = 0;
			accounts-allow-custom-css = true;
		};
		environmentFile = config.age.secrets.gotosocial_environment_file.path;
	};

  systemd.services.gotosocial = {
    after = [ "authelia-main.service" ];
    serviceConfig = {
      Restart = "on-failure";
    };
  };
}
