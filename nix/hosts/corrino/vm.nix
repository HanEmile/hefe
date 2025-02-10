{ pkgs, ... }:

{
  services.emile.libvirtnix = {
    enable = true;
    instances = {

      vm1 = {
        domain = {
          name = "VM1";
          title = "vm one";
          description = "The first VM";
          id = 1;

          uuid = "E34DE478-1402-45BB-B3FD-FC960549258E";
          genid = "CA1E2462-1E9D-404C-8DDB-19EEF9D9651B";

          packages = {
            libvirt = pkgs.libvirt;
            qemu = pkgs.qemu;
          };
          memory = 1024;
        };
      };

      vm2 = {
        domain = {
          name = "VM2";
          title = "vm one";
          description = "The second VM";
          id = 2;

          uuid = "E34DE478-1402-45BB-B3FD-FC960549258E";
          genid = "002D0D8F-B21A-4001-92BF-2313707EED9D";

          memory = 2048;
        };
      };

    };
  };
}
