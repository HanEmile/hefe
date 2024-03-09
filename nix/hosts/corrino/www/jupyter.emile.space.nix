{ pkgs, lib, config, ... }:

{
  services.nginx.virtualHosts."jupyter.emile.space" = {
    forceSSL = true;
    enableACME = true;

    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8004";
      };
    };
  };

  services.jupyter = rec {
    enable = true;

    ip = "127.0.0.1";
    port = 8004;

    # ; python3
    # >>> from notebook.auth import passwd
    # >>> passwd("the_password_here")
    password = "'argon2:$argon2id$v=19$m=10240,t=10,p=8$WdU+DaBjTaiV1IQDRJUczg$N734yZ45++Kgl26lFEZau58ru8e7P/IgL9N6sf+kw9E'";

    notebookConfig = ''
      c.NotebookApp.allow_remote_access = True
      c.NotebookApp.allow_origin = '*'
    '';

    kernels = {
      python3 = let
        env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
                ipykernel
              ]));
      in {
        displayName = "Python 3";
        argv = [
          "${env.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
        #logo32 = "${env.sitePackages}/ipykernel/resources/logo-32x32.png";
        #logo64 = "${env.sitePackages}/ipykernel/resources/logo-64x64.png";
        extraPaths = {
          "cool.txt" = pkgs.writeText "cool" "cool content";
        };
      };
    };

    group = "jupyter";
    user = "jupyter";
  };

  users.users.jupyter.group = "jupyter";
  users.groups.jupyter = {};
}