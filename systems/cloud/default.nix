{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel

  my = {
    disko = {
      root-disk = "/dev/sda";
      encrypted = true;
      legacy-boot = true;
      remote-unlocking = true;
    };

    server = {
      enable = true;
      # paperless.enable = true;

      teamspeak.enable = true;
    };
  };

  networking.hostName = "cloud";
}
