{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."md.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://[${config.services.hedgedoc.settings.host}]:${toString config.services.hedgedoc.settings.port}";
      };
    };
  };

  age.secrets.hedgedoc_oidc_client_secret.owner = "authelia-main";
  age.secrets.hedgedoc_oidc_client_secret.group = "authelia-main";
  
  # auth via authelia
  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "HedgeDoc";

      # ; nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
      client_secret = "{{ secret \"${config.age.secrets.hedgedoc_oidc_client_secret.path}\" }}";
      public = false;
      authorization_policy = "two_factor";
      redirect_uris = [ "https://md.emile.space/auth/oauth2/callback" ];
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

  services.hedgedoc = {
    enable = true;
    package = pkgs.hedgedoc;

    environmentFile = config.age.secrets.hedgedoc_environment_variables.path;

    settings = {
      host = "::1";
      port = config.emile.ports.md;

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

      allowOrigin = with config.services.hedgedoc.settings; [
        host
        domain
      ];
    };
  };

  services.restic.backups."corrino" = {
    paths = [ "/var/lib/hedgedoc" ];
  };

  services.restic.backups."hedgedoc" = {
    repository = "/mnt/storagebox-bx11/hedgedoc";
    paths = [ "/var/lib/hedgedoc" ];
    passwordFile = config.age.secrets.restic_password.path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
