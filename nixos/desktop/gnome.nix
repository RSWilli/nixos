{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.gnome;
in {
  options.my.desktop.gnome = {
    enable = mkEnableOption "gnome desktop";
  };
  config = mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;

    environment.systemPackages = with pkgs; [
      # gnome3.gpaste currently broken, see https://github.com/NixOS/nixpkgs/issues/92265
      adwaita-icon-theme
      arc-theme
      # easyeffects
      gnome-tweaks
    ];

    environment.gnome.excludePackages = with pkgs; [
      epiphany # web browser
      #gedit # text editor
      #gnome-characters
      #gnome-terminal
      cheese # webcam tool
      # evince # document viewer
      geary # email reader
      gnome-connections
      gnome-contacts
      gnome-initial-setup
      gnome-maps
      gnome-music
      gnome-photos
      gnome-tour
      yelp # Help view
    ];

    services.gnome = {
      games.enable = false;
    };
  };
}
