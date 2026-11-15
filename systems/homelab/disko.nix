{
  # 2TB nvme: system root
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";

    content.type = "gpt";

    content.partitions.ESP = {
      size = "512M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = ["umask=0077"];
      };
    };

    content.partitions.luks = {
      name = "root";
      size = "100%";
      content = {
        type = "luks";
        name = "crypted";
        settings.allowDiscards = true;

        content = {
          type = "btrfs";
          extraArgs = ["-f"];

          subvolumes = {
            "/rootfs" = {
              mountpoint = "/";
              mountOptions = ["compress=zstd" "noatime"];
            };

            "/nix" = {
              mountpoint = "/nix";
              mountOptions = ["compress=zstd" "noatime"];
            };
          };

          mountpoint = "/partition-root";
        };
      };
    };
  };

  # old sda drive: backups
  disko.devices.disk.backup = {
    type = "disk";
    device = "/dev/sda";

    content.type = "gpt";

    content.partitions.luks = {
      name = "backup";
      size = "100%";
      content = {
        type = "luks";
        name = "crypted-backup";
        settings = {
          allowDiscards = true;
          # a dead backup drive must not block the boot
          crypttabExtraOpts = ["nofail"];
        };

        content = {
          type = "btrfs";
          extraArgs = ["-f"];

          subvolumes = {
            "/backup" = {
              mountpoint = "/backup";
              mountOptions = ["compress=zstd" "noatime" "nofail"];
            };
          };

          mountpoint = "/partition-backup";
          mountOptions = ["nofail"];
        };
      };
    };
  };
}
