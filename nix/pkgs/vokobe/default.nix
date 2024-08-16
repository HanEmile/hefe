{ pkgs, naersk, ... }:

let
	naersk' = pkgs.callPackage naersk {};
in naersk'.buildPackage {
	src = ./.;

	meta = with pkgs.lib; {
		description = "A minimal static site generator tailored to my needs.";
		homepage    = "https://git.emile.space/hanemile/vokobe";
		license     = licenses.mit;
		platforms   = platforms.all;
		maintainers = with maintainers; [ hanemile ];
	};
}

