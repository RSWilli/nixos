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
    ../../nixos/system.nix
    ../../nixos/user-willi.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13

    inputs.disko.nixosModules.disko
    ../../disko/encrypted.nix
  ];

  # use a newer linux kernel
  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  my.root-disk = "/dev/nvme0n1";

  networking.hostName = "think";
}
