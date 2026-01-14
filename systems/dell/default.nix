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

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "dell";
}
