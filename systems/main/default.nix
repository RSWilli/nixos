{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos
    ./hardware-configuration.nix
    ../../nixos/gnome.nix
    ../../nixos/steam.nix
    ../../nixos/comms.nix
    ../../nixos/system.nix
    ../../nixos/tailscale.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../nixos/nvidia.nix

    inputs.disko.nixosModules.disko
    ../../disko/unencrypted.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance
  # boot.kernelPackages = pkgs.alternate.linuxPackages_latest; # pinned latest kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my.root-disk = "/dev/nvme0n1";

  networking.hostName = "main";

  environment.systemPackages = with pkgs; [
    blender
  ];
}
