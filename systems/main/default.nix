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

    ai.enable = true;

    desktop = {
      enable = true;

      amd = true;

      steam = true;

      gamedev.enable = true;

      communication = {
        mumble = true;
        matrix = true;
        discord = true;
        teamspeak = true;
      };

      vm.enable = false;
    };

    minecraft.enable = false;

    docker.enable = true;

    users = {
      willi.enable = true;
      guest.enable = true;
    };
  };

  networking.hostName = "main";

  environment.systemPackages = with pkgs; [
    obsidian
    appimage-run
    # blender-hip # blender with AMD HIP support
    xournalpp
  ];

  environment.sessionVariables = {
    # Radeon RX 7800XT needs for ROCm 11.0.0 as per: https://llvm.org/docs/AMDGPUUsage.html
    # defined by the gfx1100
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  };
}
