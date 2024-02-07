{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/gnome.nix
    ../../nixos/i18n.nix
    ../../nixos/nix.nix
    ../../nixos/steam.nix
    ../../nixos/comms.nix
    ../../nixos/system.nix
    ../../nixos/user-willi.nix
    inputs.home-manager.nixosModules.home-manager

    ../../nixos/nvidia.nix

    inputs.disko.nixosModules.disko
    ../../disko/unencrypted.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my.root-disk = "/dev/nvme0n1";

  networking.hostName = "main";
}
