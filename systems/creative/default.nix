{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # FIXME: when they release a module for the core series 300
    # https://github.com/NixOS/nixos-hardware/tree/master/framework/12-inch/13th-gen-intel
    inputs.nixosHardware.nixosModules.framework-12-13th-gen-intel
  ];

  boot = {
    # https://nixos.wiki/wiki/Linux_kernel
    kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
    plymouth.enable = true;
    kernelParams = [
      "quiet" # suppress "scary" boot messages
    ];
  };

  # Laptop battery optimizations https://nixos.wiki/wiki/Laptop
  powerManagement.enable = true;

  my = {
    autoUpgrade.enable = true;
    luksAutoUnlock.enable = true;

    desktop = {
      kde.enable = true;

      steam = true;
    };

    users = {
      lara.enable = true;
    };
  };

  services.framework-control.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    thunderbird
    libreoffice

    affinity-v3
  ];

  # fingerprint sensor, see https://wiki.nixos.org/wiki/Fingerprint_scanner
  # run `fprintd-enroll` to enroll a fingerprint
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  # BIOS updates, run `fwupdmgr update` to check for updates and install them
  # https://wiki.nixos.org/wiki/Fwupd
  services.fwupd.enable = true;

  networking.hostName = "creative";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.11";
}
