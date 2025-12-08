{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance

  boot.kernelParams = [
    # c2:00.0 Network controller: MEDIATEK Corp. Device 7925
    # Subsystem: Foxconn International, Inc. Device e137
    # Kernel driver in use: mt7925e
    # Kernel modules: mt7925e
    #
    # disable power management to avoid connectivity issues
    "mt7925e.disable_aspm=1"
  ];

  my = {
    disko = {
      root-disk = "/dev/nvme0n1";
      encrypted = true;
    };

    docker.enable = true;

    desktop = {
      enable = true;
      enableAutoLogin = true;

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
  networking.networkmanager.wifi.powersave = false;

  # use newer linux-firmware for to fix wifi issues
  nixpkgs.overlays = [
    (self: super: {
      linux-firmware = super.linux-firmware.overrideAttrs (oldAttrs: {
        version = "willi-custom1";
        src = super.fetchFromGitLab {
          owner = "kernel-firmware";
          repo = "linux-firmware";
          rev = "536cc58d9db164b0e2a47f7f33996b0cf194691a";
          hash = "sha256-cXsLhF8+5cjRf/cq0yJiNX4midGtotd4XBB7lw7mkBU=";
        };
      });
    })
  ];

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "dell";
}
