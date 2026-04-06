{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  config = mkIf (cfg.gnome.enable || cfg.cosmic.enable) {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.memtest86.enable = true;
  };
}
