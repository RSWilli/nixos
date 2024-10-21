{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # https://nixos.wiki/wiki/Linux_kernel
  boot.kernelPackages = pkgs.linuxPackages_latest; # latest stable kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance
  # boot.kernelPackages = pkgs.alternate.linuxPackages_latest; # pinned latest kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my = {
    disko = {
      root-disk = "/dev/nvme0n1";
      encrypted = false;
    };

    desktop = {
      enable = true;

      amd = true;

      steam = true;

      communication = {
        mumble = true;
        matrix = true;
        discord = true;
        teamspeak = true;
      };

      vm.enable = true;
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
    blender-hip # blender with AMD HIP support
  ];
}
