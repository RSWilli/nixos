# source: https://nixos.wiki/wiki/Nvidia
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Ozone Wayland support in Chrome and several Electron apps (needed for vscode to render in Wayland)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
