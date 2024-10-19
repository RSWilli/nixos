{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.disko;
in {
  config = mkIf (cfg.encrypted && cfg.legacy-boot) {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = cfg.root-disk;
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                size = "512M";
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
