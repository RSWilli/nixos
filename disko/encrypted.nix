{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my;
in
  with lib; {
    options = {
      my.root-disk = mkOption {
        default = "/dev/nvme0n1";
        type = with types; string;
        description = ''
          The root disk that disko formats.
        '';
      };
    };

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
  }
