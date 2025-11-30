{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance

  my = {
    disko = {
      root-disk = "/dev/nvme0n1";
      encrypted = true;
    };

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
      vpn = true;
      apps = true;
    };
  };

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "latitude";
}
