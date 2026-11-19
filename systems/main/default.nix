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
  # boot.kernelPackages = pkgs.linuxPackages_zen; # zen kernel, patched for everyday desktop performance
  # boot.kernelPackages = pkgs.alternate.linuxPackages_latest; # pinned latest kernel
  # boot.kernelPackages = pkgs.linuxPackages; # latest LTS kernel

  my = {
    claude.enable = true;

    wifi.cleanup.enable = true;

    desktop = {
      niri.enable = true;

      amd = true;

      steam = true;

      # gamedev.enable = true;

      communication = {
        mumble = true;
        matrix = true;
        discord = true;
        teamspeak = true;
      };

      vm.enable = false;
    };

    minecraft.enable = true;

    docker.enable = true;

    users = {
      willi.enable = true;
      guest.enable = true;
    };
  };

  networking.hostName = "main";

  environment.systemPackages = with pkgs; [
    obsidian
    # appimage-run
    # blender-hip # blender with AMD HIP support
    xournalpp
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.11";
}
