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

  my.root-disk = "/dev/nvme0n1";

  networking.hostName = "think";
}
