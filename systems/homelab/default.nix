{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel

  my = {
    server = {
      enable = true;
      paperless.enable = true;
      immich.enable = true;
      teamspeak.enable = true;
    };

    luksAutoUnlock.enable = true;

    backup.enable = true;
  
    wifi.enable = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "homelab";
}
