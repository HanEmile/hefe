{ config, pkgs, ... }:

let
	authelia_port = config.services.authelia.instances.main.settings.server.port;
in {

	services.nginx.virtualHosts."sso.emile.space" = {
		forceSSL = true;
		enableACME = true;

		locations = {
			"/" = {
				proxyPass = "http://127.0.0.1:${toString authelia_port}";

				extraConfig = ''
					## Headers
					proxy_set_header Host $host;
					proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
					proxy_set_header X-Forwarded-Proto $scheme;
					proxy_set_header X-Forwarded-Host $http_host;
					proxy_set_header X-Forwarded-URI $request_uri;
					proxy_set_header X-Forwarded-Ssl on;
					proxy_set_header X-Forwarded-For $remote_addr;
					proxy_set_header X-Real-IP $remote_addr;

					## Basic Proxy Configuration
					client_body_buffer_size 128k;
					proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
					proxy_redirect  http://  $scheme://;
					proxy_http_version 1.1;
					proxy_cache_bypass $cookie_session;
					proxy_no_cache $cookie_session;
					proxy_buffers 64 256k;

					## Trusted Proxies Configuration
					## Please read the following documentation before configuring this:
					##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
					# set_real_ip_from 10.0.0.0/8;
					# set_real_ip_from 172.16.0.0/12;
					# set_real_ip_from 192.168.0.0/16;
					# set_real_ip_from fc00::/7;
					set_real_ip_from 127.0.0.1/32;
					real_ip_header X-Forwarded-For;
					real_ip_recursive on;

					## Advanced Proxy Configuration
					send_timeout 5m;
					proxy_read_timeout 360;
					proxy_send_timeout 360;
					proxy_connect_timeout 360;
				'';
			};

			"/api/verify" = {
				proxyPass = "http://127.0.0.1:${toString authelia_port}";
	    };

	    "/api/authz/" = {
				proxyPass = "http://127.0.0.1:${toString authelia_port}";
	    };
		};
	};

	# set the permissions for the secrets...
	age.secrets = {
		# ... passwed via environment vars
		authelia_session_secret.owner = "authelia-main";
		authelia_session_secret.group = "authelia-main";
		authelia_mail_password.owner = "authelia-main";
		authelia_mail_password.group = "authelia-main";

		# ... passed via the services.authelia.instances.main.secrets attribute
		authelia_storage_encryption_key.owner = "authelia-main";
		authelia_storage_encryption_key.group = "authelia-main";
		authelia_jwt_secret.owner = "authelia-main";
		authelia_jwt_secret.group = "authelia-main";
		authelia_oidc_issuer_private_key.owner = "authelia-main";
		authelia_oidc_issuer_private_key.group = "authelia-main";
		authelia_oidc_hmac_secret.owner = "authelia-main";
		authelia_oidc_hmac_secret.group = "authelia-main";
	};


	services.authelia.instances = {
		main = {
			enable = true;
			package = pkgs.authelia;

			# pass some of the secrets in as env-vars
			environmentVariables = with config.age.secrets; {
				AUTHELIA_SESSION_SECRET_FILE = authelia_session_secret.path;
				AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = authelia_mail_password.path;
			};
			secrets = with config.age.secrets; {
				manual = true;

				# some other secrets can be defined here, but not all...
				storageEncryptionKeyFile = authelia_storage_encryption_key.path;
				jwtSecretFile = authelia_jwt_secret.path;
				oidcIssuerPrivateKeyFile = authelia_oidc_issuer_private_key.path;
				oidcHmacSecretFile = authelia_oidc_hmac_secret.path;
			};
			settings = {
				theme = "dark";

				server = {
					host = "127.0.0.1";
					port = config.emile.ports.authelia;
				};

				# we're using a file to store the user information
				authentication_backend = {
					refresh_interval = "20s";
					file = {
						path = "/var/lib/authelia-main/user.yml";
						watch = true;
						password = {
							algorithm = "argon2id";
							iterations = 3;
							key_length = 32;
							salt_length = 16;
							memory = 65;
							parallelism = 4;
						};
					};
				};

				storage.local.path = "/var/lib/authelia-main/db.sqlite";

				session = {
					domain = "sso.emile.space";
					expiration = 3600; # 1 hour
					inactivity = 300; # 5 minutes
				};

				notifier = {
					disable_startup_check = false;
					smtp = {
						host = "mail.emile.space";
						port = 587;
						timeout = "30s";
						username = "mail@emile.space";

						sender = "mail@emile.space";
						subject = "[Authelia] {title}";

						disable_require_tls = false;
						disable_starttls = false;
						disable_html_emails = true;

						tls = {
							server_name = "mail.emile.space";
							skip_verify = true;
							minimum_version = "TLS1.3";
						};
					};
				};

				identity_providers = {
					oidc = {
							# regenerate keys like this:
							# ; nix run nixpkgs#authelia -- crypto certificate rsa generate
							# current serial: deb83f17e27e663f544a16ad2947631d

							enable_client_debug_messages = false;
							minimum_parameter_entropy = 8;
							enforce_pkce = "public_clients_only";
							enable_pkce_plain_challenge = false;
							cors = {
							endpoints = [
								"authorization"
								"token"
								"revocation"
								"introspection"
							];
							allowed_origins = [
								"https://emile.space"
							];
							allowed_origins_from_client_redirect_uris = false;
						};
					};
				};

				access_control = {
					default_policy = "deny";
					rules = [
						{
							domain = "*.emile.space";
							policy = "two_factor";
						}
					];
				};

				totp = {
				  disable = true;
				  issuer = "sso.emile.space";
				  algorithm = "sha1";
				  digits = 6;
				  period = 30;
				  skew = 1;
				  secret_size = 32;
				};

				ntp = {
				  address = "time.cloudflare.com:123";
				  version = 3;
				  max_desync = "3s";
				  disable_startup_check = false;
				  disable_failure = false;
				};
			};
		};
	};
}
