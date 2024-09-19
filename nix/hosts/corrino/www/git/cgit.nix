{
  config,
  lib,
  pkgs,
  ...
}:

let
  repodirs = builtins.concatStringsSep "\n" (
    map (x: "directory = ${x}") (
      lib.lists.flatten (
        map (x: lib.attrValues (lib.getAttrs [ "path" ] x)) (
          lib.mapAttrsToList (name: value: value) config.services.cgit.main.repos
        )
      )
    )
  );
in
{
  environment.systemPackages = with pkgs; [
    md4c # used to get md2html for rendering the READMEs within cgit-pink
  ];

  # set all the repos as safe
  environment.etc = {
    gitconfig = {
      text = ''
        			[http]
        				sslCAinfo = /etc/ssl/certs/ca-certificates.crt
        			[safe]
        				${repodirs}
            '';
    };
  };

  services = {
    nginx.virtualHosts."git.emile.space" = {
      forceSSL = true;
      enableACME = true;
    };

    cgit.main = {
      enable = true;
      package = pkgs.cgit-pink;
      nginx.virtualHost = "git.emile.space";
      nginx.location = "/";
      repos = {

        # ops
        hefe = {
          desc = "Yet another monorepo (the big nix config)";
          path = "/var/lib/git/repositories/hefe.git";
          section = "Infra";
          owner = "emile";
        };
        vokobe = {
          desc = "A custom static site generator written in rust";
          path = "/var/lib/git/repositories/vokobe.git";
          section = "Infra";
          owner = "emile";
        };
        massscan-docker = {
          desc = "A Dockerfile for massscan";
          path = "/var/lib/git/repositories/massscan-docker.git";
          section = "Infra";
          owner = "emile";
        };
        metrics-bundler = {
          desc = "A super basic metrics bundler";
          path = "/var/lib/git/repositories/metrics-bundler.git";
          section = "Infra";
          owner = "emile";
        };

        # matrix
        matrix-sdk = {
          desc = "A simpler matrix sdk";
          path = "/var/lib/git/repositories/matrix-sdk.git";
          section = "Matrix";
          owner = "emile";
        };
        matrix-weather-bot = {
          desc = "A basic weather bot using matrix-sdk";
          path = "/var/lib/git/repositories/matrix-weather-bot.git";
          section = "Matrix";
          owner = "emile";
        };

        # radare2
        radare2-GoReSym = {
          desc = "A script to load goresym symbols into radare2";
          path = "/var/lib/git/repositories/radare2-GoReSym.git";
          section = "Radare2";
          owner = "emile";
        };
        r2wars = {
          desc = "A golang implementation of radare2";
          path = "/var/lib/git/repositories/r2wars.git";
          section = "Radare2";
          owner = "emile";
        };
        r2wars-web = {
          desc = "The software behind https://r2wa.rs";
          path = "/var/lib/git/repositories/r2wars-web.git";
          section = "Radare2";
          owner = "emile";
        };
        r2wars-rs = {
          desc = "A rust implementation of radare2";
          path = "/var/lib/git/repositories/r2wars-rs.git";
          section = "Radare2";
          owner = "emile";
        };

        # ctf
        ctf_clusters = {
          desc = "visualizing CTF clusters at DEFCON CTF Finals 2022";
          path = "/var/lib/git/repositories/ctf_clusters.git";
          section = "CTF";
          owner = "emile";
        };
        lambda = {
          desc = "hacktm ctf 2023 / misc / know your lambda calculus";
          path = "/var/lib/git/repositories/lambda.git";
          section = "CTF";
          owner = "emile";
        };
        ctfdget = {
          desc = "Simply fetch all challenges from a CTF from CTFd.";
          path = "/var/lib/git/repositories/ctfdget.git";
          section = "CTF";
          owner = "emile";
        };

        # keyboard
        zmk-config = {
          desc = "ferris sweep zmk config";
          path = "/var/lib/git/repositories/zmk-config.git";
          section = "Keyboard";
          owner = "emile";
        };

        # chaosdorf
        map = {
          desc = "A map of the chaosdorf hackspace";
          path = "/var/lib/git/repositories/map.git";
          section = "Chaosdorf";
          owner = "emile";
        };
        freitagsfoo = {
          desc = "A service to submit talks for freitagsfoo";
          path = "/var/lib/git/repositories/freitagsfoo.git";
          section = "Chaosdorf";
          owner = "emile";
        };
        inventory = {
          desc = "A common-lisp mapping and inventory system";
          path = "/var/lib/git/repositories/inventory.git";
          section = "Chaosdorf";
          owner = "emile";
        };

        # jugend forscht
        SatelliteComputation = {
          desc = "Estimating possible Satellite collisions";
          path = "/var/lib/git/repositories/SatelliteComputation.git";
          section = "Jugend Forscht 2017";
          owner = "emile";
        };
        GalaxyGeneration = {
          desc = "Generating Galaxies";
          path = "/var/lib/git/repositories/GalaxyGeneration.git";
          section = "Jugend Forscht 2018";
          owner = "emile";
        };

        brute-force = {
          desc = "A simple benchmark showing how slow this can be";
          path = "/var/lib/git/repositories/galaxy-sim-brute-force.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        generatePointcloud = {
          desc = "Generate pointclouds using the NFW profile";
          path = "/var/lib/git/repositories/generatePointcloud.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        quadtree = {
          desc = "Simple quadtree implementation";
          path = "/var/lib/git/repositories/quadtree.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        viewer = {
          desc = "A viewer for galaxies stored in trees";
          path = "/var/lib/git/repositories/viewer.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        structs = {
          desc = "All of the structures used in the GalaxySimulator";
          path = "/var/lib/git/repositories/structs.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        simulator-container-rewrite = {
          desc = "Clean rewrite of the simulator-container";
          path = "/var/lib/git/repositories/simulator-container-rewrite.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        simulator-container = {
          desc = "Simulating the new position of a galaxye";
          path = "/var/lib/git/repositories/simulator-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        pres = {
          desc = "Presentation material";
          path = "/var/lib/git/repositories/pres.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        manager-container = {
          desc = "The overall manager";
          path = "/var/lib/git/repositories/manager-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        generator-container = {
          desc = "Generates point clouds using the NFW profile";
          path = "/var/lib/git/repositories/generator-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        frontpage = {
          desc = "Web page showing people what the project is about";
          path = "/var/lib/git/repositories/frontpage.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        distributor = {
          desc = "Distributing tasks";
          path = "/var/lib/git/repositories/distributor-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        db-controller = {
          desc = "Interaction with the Database";
          path = "/var/lib/git/repositories/db-controller.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        db-container = {
          desc = "The main database";
          path = "/var/lib/git/repositories/db-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        db-actions = {
          desc = "Actions to be performed on the batabase";
          path = "/var/lib/git/repositories/db-actions.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        Writeup = {
          desc = "Writeups using LaTeX";
          path = "/var/lib/git/repositories/Writeup.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        Source = {
          desc = "Code from the beginning";
          path = "/var/lib/git/repositories/Source.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };
        NFW-container = {
          desc = "A container purely for generating galaxies";
          path = "/var/lib/git/repositories/NFW-container.git";
          section = "Jugend Forscht 2019";
          owner = "emile";
        };

        # games
        "0h-gamejam-game" = {
          desc = "Created a game in 0 hours";
          path = "/var/lib/git/repositories/0hour-gamejam-game.git";
          section = "Games";
          owner = "emile";
        };

        # 3D
        "3D" = {
          desc = "3D models";
          path = "/var/lib/git/repositories/3D.git";
          section = "3D";
          owner = "emile";
        };

        # http
        faila = {
          desc = "The caddy fileserver look, but int pure golang";
          path = "/var/lib/git/repositories/faila.git";
          section = "HTTP";
          owner = "emile";
        };
        faila2 = {
          desc = "faila, but simpler";
          path = "/var/lib/git/repositories/faila2.git";
          section = "HTTP";
          owner = "emile";
        };
        gofuzz = {
          desc = "wfuzz, but in go. Didn't know ffuf at the time";
          path = "/var/lib/git/repositories/gofuzz.git";
          section = "HTTP";
          owner = "emile";
        };
        graphClicker = {
          desc = "A metrics bundler, but with a simple web interface";
          path = "/var/lib/git/repositories/graphClicker.git";
          section = "HTTP";
          owner = "emile";
        };
        randomHttp = {
          desc = "A simple HTTP server returning random HTTP codes";
          path = "/var/lib/git/repositories/randomHTTP.git";
          section = "HTTP";
          owner = "emile";
        };
        redir = {
          desc = "A webserver with the soul purpose of redirecting.";
          path = "/var/lib/git/repositories/redir.git";
          section = "HTTP";
          owner = "emile";
        };
        reqlog = {
          desc = "A simple request logger";
          path = "/var/lib/git/repositories/reqlog.git";
          section = "HTTP";
          owner = "emile";
        };

        # honeypot
        ssh-catch-test = {
          desc = "A simple honeypot emulating an ssh server.";
          path = "/var/lib/git/repositories/ssh-catch-test.git";
          section = "Honeypot";
          owner = "emile";
        };
        honeypot-monitoring = {
          desc = "Grafana + Prometheus monitoring";
          path = "/var/lib/git/repositories/honeypot-monitoring.git";
          section = "Honeypot";
          owner = "emile";
        };
        ftp-grab-password = {
          desc = "Grab ftp creds (made by twink0r)";
          path = "/var/lib/git/repositories/ftp-grab-password.git";
          section = "Honeypot";
          owner = "emile";
        };
        log-analyzer = {
          desc = "Analyse the logs";
          path = "/var/lib/git/repositories/honeypot-log-analyzer.git";
          section = "Honeypot";
          owner = "emile";
        };
        http-grab-basicauth = {
          desc = "Grab basicauth creds (made by maride)";
          path = "/var/lib/git/repositories/http-grab-basicauth.git";
          section = "Honeypot";
          owner = "emile";
        };
        http-grab-url = {
          desc = "Grab urls (made by twink0r)";
          path = "/var/lib/git/repositories/http-grab-url.git";
          section = "Honeypot";
          owner = "emile";
        };
        ssh-grab-keypass = {
          desc = "Grab keys from ssh logins (made by maride)";
          path = "/var/lib/git/repositories/ssh-grab-keypass.git";
          section = "Honeypot";
          owner = "emile";
        };
        ssh-grab-passwords = {
          desc = "Grab passwords from ssh logins (made by maride)";
          path = "/var/lib/git/repositories/ssh-grab-passwords.git";
          section = "Honeypot";
          owner = "emile";
        };
        ssh-grab-passwords-map = {
          desc = "A nice visual map of the login attempts";
          path = "/var/lib/git/repositories/ssh-grab-passwords-map.git";
          section = "Honeypot";
          owner = "emile";
        };

        # fuzzing
        stdin-to-tcp = {
          desc = "Bending stdin to tcp";
          path = "/var/lib/git/repositories/stdin-to-tcp.git";
          section = "Fuzzing";
          owner = "emile";
        };

        # firmware
        firmware = {
          desc = "Gathering firmware via nix";
          path = "/var/lib/git/repositories/firmware.git";
          section = "Firmware";
          owner = "emile";
        };

        # crypto
        Substitution-Cracker = {
          desc = "Some code for cracking substitution ciphers";
          path = "/var/lib/git/repositories/Substitution-Cracker.git";
          section = "Crypto";
          owner = "emile";
        };

        # fun
        giff = {
          desc = "A party service: give it gifs and it'll play them";
          path = "/var/lib/git/repositories/giff.git";
          section = "Fun";
          owner = "emile";
        };
        pixeltsunami = {
          desc = "The obligatory pixelflut client";
          path = "/var/lib/git/repositories/pixeltsunami.git";
          section = "Fun";
          owner = "emile";
        };

        # circus
        companion = {
          desc = "The companion spawned for one user.";
          path = "/var/lib/git/repositories/companion.git";
          section = "Circus";
          owner = "emile";
        };
        compose = {
          desc = "The docker-compose foo";
          path = "/var/lib/git/repositories/compose.git";
          section = "Circus";
          owner = "emile";
        };
        container-manager = {
          desc = "The meta container managemer";
          path = "/var/lib/git/repositories/container-manager.git";
          section = "Circus";
          owner = "emile";
        };
        landingpage = {
          desc = "The landing page";
          path = "/var/lib/git/repositories/landingpage.git";
          section = "Circus";
          owner = "emile";
        };
        manager = {
          desc = "The manager";
          path = "/var/lib/git/repositories/manager.git";
          section = "Circus";
          owner = "emile";
        };
        register = {
          desc = "The registration";
          path = "/var/lib/git/repositories/register.git";
          section = "Circus";
          owner = "emile";
        };
        scoreboard = {
          desc = "The scoreboard";
          path = "/var/lib/git/repositories/scoreboard.git";
          section = "Circus";
          owner = "emile";
        };
        static = {
          desc = "Some static files";
          path = "/var/lib/git/repositories/static.git";
          section = "Circus";
          owner = "emile";
        };
        vpn = {
          desc = "The VPN stuff";
          path = "/var/lib/git/repositories/vpn.git";
          section = "Circus";
          owner = "emile";
        };

        # articles
        barnes-hut = {
          desc = "A one pager compressing the JuFo19 project";
          path = "/var/lib/git/repositories/barnes-hut.git";
          section = "Articles";
          owner = "emile";
        };

        # satellite
        tle = {
          desc = "golang tle lib";
          path = "/var/lib/git/repositories/tle.git";
          section = "Satellite";
          owner = "emile";
        };
        tle2json = {
          desc = "golang tle to json";
          path = "/var/lib/git/repositories/tle2json.git";
          section = "Satellite";
          owner = "emile";
        };
      };
      settings = {
        css = "https://emile.space/cgit.css";
        root-title = "git.emile.space";
        root-desc = "";

        enable-index-owner = 0; # why show this? I own 'em all!
        enable-commit-graph = 1;
        max-repo-count = 5000; # like: why not?

        readme = ":README.md";
        about-filter = "${pkgs.cgit-pink}/lib/cgit/filters/about-formatting.sh";
        source-filter = "${pkgs.cgit-pink}/lib/cgit/filters/syntax-highlighting.py";

        summary-log = 50;

        # mobile friendly
        head-include = builtins.toFile "cgit_head.html" ''
            <meta name="viewport" content="width=device-width initial-scale=1.0"/>
        '';

        footer = builtins.toFile "cgit_footer.html" ''
            <div class="footer">
          		<div class="float-left">
          			generated by <a href='https://git.causal.agency/cgit-pink/'>cgit-pink ${pkgs.cgit-pink.version}</a>
          		</div>
          		<div class="float-right">
          			<a href="https://social.emile.space/@hanemile/feed.rss" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/rss.svg" alt="rss feed of @hanemile@chaos.social mastodon" height="32px"></a>
          			<a href="https://lieu.cblgh.org/" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/lieu.svg" alt="lieu webring search engine" height="32px"></a>
          			<a href="https://webring.xxiivv.com/#emile" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/webring.svg" alt="XXIIVV webring" height="32px"></a>
          			<a rel="me" href="https://social.emile.space/@hanemile" target="_blank" class="icon"><img class="webring" src="https://emile.space/activitypub.svg" alt="activitypub" height="32px"/></a>
          	</div>
        '';

      };
    };

    # access control
    gitolite = {
      enable = true;

      dataDir = "/var/lib/git";

      user = "git";
      group = "git";

      description = "emile";

      adminPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew emile@caladan";
      extraGitoliteRc = ''
          $RC{UMASK} = 0027;
          $RC{GIT_CONFIG_KEYS} = '.*';
      '';
    };

    # exposing stuff
    gitDaemon = {
      enable = false;

      user = "git";
      group = "git";

      repositories = [ ]; # use all repos under basePath
      exportAll = true;
      basePath = "/var/lib/git/repositories";

      listenAddress = "git.emile.space";
      port = config.emile.ports.gitDaemon;

      options = "--timeout=30"; # extra Config
    };
  };

  users.extraUsers.nginx.extraGroups = [ "git" ];

  # Have to use lib.mkForce below, as the gitolite and gitDaemon user both
  # configure the git user and group (differently)

  users.users.git = {
    isSystemUser = true;
    useDefaultShell = true;
    description = lib.mkForce "cgit-pink, gitolite and gitDaemon";
    group = "git";
    extraGroups = [ "gitea" ];
    home = "/var/lib/git";
    uid = lib.mkForce 127;
  };
  users.groups.git = {
    gid = lib.mkForce 127;
  };
}
