{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.disko;
in {
  config = mkIf (cfg.encrypted && !cfg.legacy-boot) {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.root-disk;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "500M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
