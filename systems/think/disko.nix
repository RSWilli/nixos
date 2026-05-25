{
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
      };
    };

    content.partitions.luks = {
      name = "root";
      size = "100%";
      content = {
        type = "luks";
        name = "crypted";

        content = {
          type = "btrfs";
          extraArgs = ["-f"];

          subvolumes = {
            "/rootfs" = {
              mountpoint = "/";
              mountOptions = ["compress=zstd" "noatime"];
            };

            "/home" = {
              mountpoint = "/home";
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
}
