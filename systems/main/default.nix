{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../disko/unencrypted.nix
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance
  # boot.kernelPackages = pkgs.alternate.linuxPackages_latest; # pinned latest kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my = {
    root-disk = "/dev/nvme0n1";

    desktop = {
      enable = true;

      nvidia = true;

      steam = true;

      communication = {
        mumble = true;
        matrix = true;
        discord = true;
        teamspeak = true;
      };
    };

    user = {
      setup-private-ssh-key = true;
    };

    work = {
      apps = false;
      vpn = true;
    };
  };

  networking.hostName = "main";

  environment.systemPackages = with pkgs; [
    blender
  ];
}
