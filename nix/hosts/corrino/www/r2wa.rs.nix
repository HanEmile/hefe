{ ... }:

{
  services.nginx.virtualHosts."r2wa.rs" = {
    forceSSL = true;
    enableACME = true;

    # kTLS = true;

    locations = {
      "/" = {
				return = "301 http://emile.space/blog/2020/r2wars/";
      };
		};
	};
}
