{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.cosmic;
in {
  options.my.desktop.cosmic = {
    enable = mkEnableOption "COSMIC desktop";
  };

  config = mkIf cfg.enable {
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      pulseaudio

      cosmic-player # in favor of showtime from gnome
      cosmic-reader # in favor of papers from gnome
    ];

    environment.systemPackages = with pkgs; [
      seahorse # gnome keyring manager

      showtime
      papers
    ];

    services.system76-scheduler.enable = true;
  };
}
