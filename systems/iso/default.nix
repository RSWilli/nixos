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

    ../../nixos/gnome.nix
    ../../nixos/i18n.nix
    ../../nixos/nix.nix

    #  dont use system.nix, as the installer will configure conflicting settings
    # ../../nixos/system.nix
    ../../nixos/users.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = [];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  services.getty.autologinUser = lib.mkForce "willi";

  networking.networkmanager.enable = false;

  # override root initial password set by the installer
  users.users.root.initialHashedPassword = lib.mkForce null;
}
