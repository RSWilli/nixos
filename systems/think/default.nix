{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13

    inputs.disko.nixosModules.disko
    ../../disko/encrypted.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my = {
    root-disk = "/dev/nvme0n1";

    desktop = {
      enable = true;
    };

    user = {
      setup-private-ssh-key = true;
    };
  };

  networking.hostName = "think";
}
