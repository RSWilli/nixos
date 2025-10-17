{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/thinkpad/x13
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  # Laptop battery optimizations https://nixos.wiki/wiki/Laptop
  powerManagement.enable = true;

  my = {
    disko = {
      root-disk = "/dev/nvme0n1";
      encrypted = true;
    };

    desktop = {
      enable = true;
      enableAutoLogin = true;
    };

    users = {
      willi.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    obsidian
  ];

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "think";
}
