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
      paperless = true;

      teamspeak = true;
    };

    user = {
      setup-private-ssh-key = false;
    };
  };

  networking.hostName = "cloud";
}
