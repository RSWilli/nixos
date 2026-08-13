# Cursor theme configuration.
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;

  # Shipped as a package rather than via environment.etc so steam
  # fhs doesn't break it and the cursor theme is correctly picked up by steam UI
  gtk-cursor-settings = pkgs.writeTextFile {
    name = "gtk-cursor-settings";
    text = ''
      [Settings]
      gtk-cursor-theme-name=Adwaita
      gtk-cursor-theme-size=24
    '';
    destination = "/etc/xdg/gtk-3.0/settings.ini";
  };
in {
  config = mkIf (cfg.gnome.enable || cfg.cosmic.enable || cfg.niri.enable) {
    # provides share/icons/Adwaita, which xdg.icons puts on XCURSOR_PATH
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
      gtk-cursor-settings
    ];
  };
}
