{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-5520
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

  networking.hostName = "latitude";
}
