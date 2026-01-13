{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance

  # c2:00.0 Network controller: MEDIATEK Corp. Device 7925
  # Subsystem: Foxconn International, Inc. Device e137
  # Kernel driver in use: mt7925e
  # Kernel modules: mt7925e
  #
  # constantly drops wifi connection speed. I have an alternative usb wifi adapter.
  # disable the module entirely until a fix is found.
  boot.blacklistedKernelModules = ["mt7925e"];
  boot.extraModprobeConfig = "blacklist mt7925e";

  my = {
    disko = {
      root-disk = "/dev/nvme0n1";
      encrypted = true;
    };

    docker.enable = true;

    desktop = {
      enable = true;
      enableAutoLogin = true;

      amd = true;

      communication = {
        matrix = true;
      };
    };

    users = {
      willi.enable = true;
    };

    work = {
      enable = true;
    };
  };

  # Laptop battery optimizations https://nixos.wiki/wiki/Laptop
  powerManagement.enable = true;

  # powertop and auto tune service
  powerManagement.powertop.enable = true;

  # try to fix MediaTek wifi issues
  # networking.networkmanager.wifi.powersave = false;

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "dell";
}
