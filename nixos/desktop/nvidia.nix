# https://nixos.org/manual/nixos/unstable/#sec-x11-graphics-cards-nvidia
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop.nvidia = mkEnableOption "nvidia";

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    };
  };
}
