{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos
    ./hardware-configuration.nix
    ../../nixos/gnome.nix
    ../../nixos/system.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.dell-latitude-5520

    inputs.disko.nixosModules.disko
    ../../disko/encrypted.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel
  boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance

  my = {
    root-disk = "/dev/nvme0n1";

    user = {
      setup-private-ssh-key = true;
    };

    work-apps = true;
  };

  networking.hostName = "latitude";
}
