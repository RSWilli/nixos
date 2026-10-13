{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.kde;
in {
  options.my.desktop.kde = {
    enable = mkEnableOption "KDE desktop";
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    # Default display manager for Plasma
    services.displayManager.plasma-login-manager.enable = true;

    my.wifi.enable = true;
    hardware.bluetooth.enable = true;
  };
}
