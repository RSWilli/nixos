{pkgs, ...}: {
  imports = [
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel

  my = {
    server = {
      enable = true;
      # paperless.enable = true;

      teamspeak.enable = true;
    };
  };

  networking.hostName = "cloud";
}
