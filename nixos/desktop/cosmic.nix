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
    ];

    services.system76-scheduler.enable = true;
  };
}
