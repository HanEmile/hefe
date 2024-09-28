{ config, ... }:

{
  services.nginx.virtualHosts."photo.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}";
      };
    };
  };

	services.immich = {
		enable = true;
		mediaLocation = "/var/lib/immich";
    secretsFile = config.age.secrets.immich_secrets_file.path;

		host = "127.0.0.1";
		port = config.emile.ports.immich;

		machine-learning = {
			enable = true;
			environment = {
				MACHINE_LEARNING_MODEL_TTL = "600";
			};
		};
	};
}
