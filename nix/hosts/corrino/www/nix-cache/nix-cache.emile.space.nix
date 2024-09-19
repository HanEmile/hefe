{ ... }:

{
  services.nginx.virtualHosts."nix-cache.emile.space" = {
    forceSSL = false;
    enableACME = false;
  };
  #   locations = {
  #     "/" = {
  #       root = "/var/www/emile.space";
  #       extraConfig = ''
  #         add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  #       ''; 
  #     };
  # };
  # locations."= /" = {
  # 	index = "/index.txt";
  # };
  #   locations."= /index.txt" = {
  #     root = ./index.txt;
  #   };
  #   locations."= /nix/store/" = {
  #     extraConfig = ''
  #       return 404;
  #     '';
  #   };
  #   locations."/nix/store/" = {
  #     root = "/";
  #     extraConfig = ''
  #       autoindex on;
  #       autoindex_exact_size off;
  #     '';
  #   };
  #   locations."/" = {
  # 	proxyPass = "http://${config.services.harmonia.settings.bind}";
  # 	extraConfig = ''
  #      proxy_set_header Host $host;
  #      proxy_redirect http:// https://;
  #      proxy_http_version 1.1;
  #      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #      proxy_set_header Upgrade $http_upgrade;
  #      proxy_set_header Connection $connection_upgrade;

  #      zstd on;
  #      zstd_types application/x-nix-archive;
  # 	'';
  # };
  # };

  #  services.harmonia = {
  # 	enable = true;

  # 	# TODO(emile): manage this using age
  # 	signKeyPath = "/var/lib/secrets/harmonia.secret";

  #    settings.bind = "[::1]:${toString config.emile.ports.harmonia}";
  # };
}
