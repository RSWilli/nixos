{
  inputs,
  modulesPath,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # ../../nixos/gnome.nix
    ../../nixos/i18n.nix
    ../../nixos/nix.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = [];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
