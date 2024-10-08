{ config, lib, ... }:

let

  inherit (builtins) toJSON;
  inherit (lib) mergeAttrsList mapAttrsToList;

  # get's all repos configured in cgit and converts them into some JSON that is used by hound
  repos = toJSON (
    mergeAttrsList (
      map (x: {
        "${x.name}" = {
          url = "file://${x.path}";
        };
      }) (mapAttrsToList (name: value: value // { name = "${name}"; }) config.services.cgit.main.repos)
    )
  );

  cfg = config.services.hound;
in
{
  services.nginx.virtualHosts."cs.emile.space" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://${cfg.listen}";
      };
    };
  };

  # add hound user to git group so the local repos can be read
  # users.users.hound.extraGroups = [ "git" ];

  users.groups."git".members = [ "hound" ];

  # The `.gitignore` of the user `hound` should contain the following:
  #
  # [safe]
  #       directory = /var/lib/git/repositories/*
  #       directory = /var/lib/git/repositories/faila.git
  #       directory = /var/lib/git/repositories/faila2.git

  services.hound = {
    enable = true;

    config = ''
      			{
      			  "dbpath": "/var/lib/hound/data",
      			  "max-concurrent-indexers" : 6,
      		    "vcs-config" : {
      	        "git" : {
                  "detect-ref" : true
      	        }
      		    },
      			  "repos" : ${repos}
      			}
      		'';

    listen = "127.0.0.1:${toString config.emile.ports.hound}";
  };
}
