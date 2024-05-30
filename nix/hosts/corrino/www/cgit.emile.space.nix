{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
	  md4c # used to get md2html for rendering the READMEs
	];

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
					section = "infra";
					owner = "emile";
				};
				vokobe = {
					desc = "A custom static site generator written in rust";	
					path = "/var/lib/git/repositories/vokobe.git";
					section = "infra";
					owner = "emile";
				};
				massscan-docker = {
					desc = "A Dockerfile for massscan";	
					path = "/var/lib/git/repositories/massscan-docker.git";
					section = "infra";
					owner = "emile";
				};
				metrics-bundler = {
					desc = "A super basic metrics bundler";	
					path = "/var/lib/git/repositories/metrics-bundler.git";
					section = "infra";
					owner = "emile";
				};

				# matrix
				matrix-sdk = {
					desc = "A simpler matrix sdk";	
					path = "/var/lib/git/repositories/matrix-sdk.git";
					section = "matrix";
					owner = "emile";
				};
				matrix-weather-bot = {
					desc = "A basic weather bot using matrix-sdk";	
					path = "/var/lib/git/repositories/matrix-weather-bot.git";
					section = "matrix";
					owner = "emile";
				};
				

        # radare2
				radare2-GoReSym = {
					desc = "A script to load goresym symbols into radare2";	
					path = "/var/lib/git/repositories/radare2-GoReSym.git";
					section = "radare2";
					owner = "emile";
				};
				r2wars = {
					desc = "A golang implementation of radare2";	
					path = "/var/lib/git/repositories/r2wars.git";
					section = "radare2";
					owner = "emile";
				};

				# ctf
				ctf_clusters = {
					desc = "visualizing CTF clusters at DEFCON CTF Finals 2022";
					path = "/var/lib/git/repositories/ctf_clusters.git";
					section = "ctf";
					owner = "emile";
				};
				lambda = {
					desc = "hacktm ctf 2023 / misc / know your lambda calculus";
					path = "/var/lib/git/repositories/lambda.git";
					section = "ctf";
					owner = "emile";
				};
				ctfdget = {
					desc = "Simply fetch all challenges from a CTF from CTFd.";
					path = "/var/lib/git/repositories/ctfdget.git";
					section = "ctf";
					owner = "emile";
				};

        # keyboard
				zmk-config = {
					desc = "ferris sweep zmk config";
					path = "/var/lib/git/repositories/zmk-config.git";
					section = "keyboard";
					owner = "emile";
				};

				# chaosdorf
				map = {
					desc = "A map of the chaosdorf hackspace";
					path = "/var/lib/git/repositories/map.git";
					section = "chaosdorf";
					owner = "emile";
				};
				freitagsfoo = {
					desc = "A service to submit talks for freitagsfoo";
					path = "/var/lib/git/repositories/freitagsfoo.git";
					section = "chaosdorf";
					owner = "emile";
				};
				inventory = {
					desc = "A common-lisp mapping and inventory system";
					path = "/var/lib/git/repositories/inventory.git";
					section = "chaosdorf";
					owner = "emile";
				};

				# jugend forscht
				SatelliteComputation = {
					desc = "Estimating possible Satellite collisions";
					path = "/var/lib/git/repositories/JUFO17_SatelliteComputation.git";
					section = "Jugend Forscht 2017";
					owner = "emile";
				};
				GalaxyGeneration = {
					desc = "Generating Galaxies";
					path = "/var/lib/git/repositories/JUFO18_GalaxyGeneration.git";
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
					section = "games";
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
					section = "http";
					owner = "emile";
				};
				faila2 = {
					desc = "faila, but simpler";
					path = "/var/lib/git/repositories/faila2.git";
					section = "http";
					owner = "emile";
				};
				gofuzz = {
					desc = "wfuzz, but in go. Didn't know ffuf at the time";
					path = "/var/lib/git/repositories/gofuzz.git";
					section = "http";
					owner = "emile";
				};
				graphClicker = {
					desc = "A metrics bundler, but with a simple web interface";
					path = "/var/lib/git/repositories/graphClicker.git";
					section = "http";
					owner = "emile";
				};
				randomHttp = {
					desc = "A simple HTTP server returning random HTTP codes";
					path = "/var/lib/git/repositories/randomHTTP.git";
					section = "http";
					owner = "emile";
				};
				redir = {
					desc = "A webserver with the soul purpose of redirecting.";
					path = "/var/lib/git/repositories/redir.git";
					section = "http";
					owner = "emile";
				};
				reqlog = {
					desc = "A simple request logger";
					path = "/var/lib/git/repositories/reqlog.git";
					section = "http";
					owner = "emile";
				};

				# honeypot
				ssh-catch-test = {
					desc = "A simple honeypot emulating an ssh server.";
					path = "/var/lib/git/repositories/ssh-catch-test.git";
					section = "honeypot";
					owner = "emile";
				};
				honeypot-monitoring = {
					desc = "Grafana + Prometheus monitoring";	
					path = "/var/lib/git/repositories/honeypot-monitoring.git";
					section = "honeypot";
					owner = "emile";
				};
				ftp-grab-password = {
					desc = "Grab ftp creds (made by twink0r)";	
					path = "/var/lib/git/repositories/ftp-grab-password.git";
					section = "honeypot";
					owner = "emile";
				};
				log-analyzer = {
					desc = "Analyse the logs";	
					path = "/var/lib/git/repositories/honeypot-log-analyzer.git";
					section = "honeypot";
					owner = "emile";
				};
				http-grab-basicauth = {
					desc = "Grab basicauth creds (made by maride)";	
					path = "/var/lib/git/repositories/http-grab-basicauth.git";
					section = "honeypot";
					owner = "emile";
				};
				http-grab-url = {
					desc = "Grab urls (made by twink0r)";	
					path = "/var/lib/git/repositories/http-grab-url.git";
					section = "honeypot";
					owner = "emile";
				};
				ssh-grab-keypass = {
					desc = "Grab keys from ssh logins (made by maride)";	
					path = "/var/lib/git/repositories/ssh-grab-keypass.git";
					section = "honeypot";
					owner = "emile";
				};
				ssh-grab-passwords = {
					desc = "Grab passwords from ssh logins (made by maride)";	
					path = "/var/lib/git/repositories/ssh-grab-passwords.git";
					section = "honeypot";
					owner = "emile";
				};
				ssh-grab-passwords-map = {
					desc = "A nice visual map of the login attempts";	
					path = "/var/lib/git/repositories/ssh-grab-passwords-map.git";
					section = "honeypot";
					owner = "emile";
				};

        # fuzzing
				stdin-to-tcp = {
					desc = "Bending stdin to tcp";
					path = "/var/lib/git/repositories/stdin-to-tcp.git";
					section = "fuzzing";
					owner = "emile";
				};

				# firmware
				firmware = {
					desc = "Gathering firmware via nix";
					path = "/var/lib/git/repositories/firmware.git";
					section = "firmware";
					owner = "emile";
				};

				# crypto
				Substitution-Cracker = {
					desc = "Some code for cracking substitution ciphers";
					path = "/var/lib/git/repositories/Substitution-Cracker.git";
					section = "crypto";
					owner = "emile";
				};

				# fun
				giff = {
					desc = "A party service: give it gifs and it'll play them";
					path = "/var/lib/git/repositories/giff.git";
					section = "fun";
					owner = "emile";
				};
				pixeltsunami = {
					desc = "The obligatory pixelflut client";
					path = "/var/lib/git/repositories/pixeltsunami.git";
					section = "fun";
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
							<a href="https://chaos.social/@hanemile.rss" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/rss.svg" alt="rss feed of @hanemile@chaos.social mastodon" height="32px"></a>
							<a href="https://lieu.cblgh.org/" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/lieu.svg" alt="lieu webring search engine" height="32px"></a>
							<a href="https://webring.xxiivv.com/#emile" target="_blank" rel="noopener" class="icon"><img class="webring" src="https://emile.space/webring.svg" alt="XXIIVV webring" height="32px"></a>
							<a rel="me" href="https://chaos.social/@hanemile" target="_blank" class="icon"><img class="webring" src="https://emile.space/mastodon.svg" alt="mastodon" height="32px"></a>
					</div>
				'';

			};
		};

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
	};

  users.extraUsers.nginx.extraGroups = [ "git" ];
}
