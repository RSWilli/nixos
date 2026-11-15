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

      domain = "w-bartel.de";

      paperless.enable = true;
      vaultwarden.enable = true;
      immich.enable = true;
      teamspeak.enable = true;
    };

    luksAutoUnlock.enable = true;

    backup.enable = true;
    backup.directory = "/backup";

    wifi.enable = true;
    wifi.cleanup.enable = true;
  };

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "homelab";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.11";
}
