# source: https://nixos.wiki/wiki/Nvidia
{
  config,
  pkgs,
  ...
}: {
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
  };

  hardware.opengl.extraPackages = with pkgs; [
    vaapiVdpau
  ];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  };

  # Ozone Wayland support in Chrome and several Electron apps (needed for vscode to render in Wayland)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
