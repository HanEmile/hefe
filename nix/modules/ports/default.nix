{ lib, ... }: 

with lib; {
  options = mkOption {
	  type = types.attrs;
	  default = false;
	  example = true;
	  description = "Whether to enable this cool module.";
  };
}
