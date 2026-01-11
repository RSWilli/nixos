{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.gamedev;
in {
  options.my.desktop.gamedev = {
    enable = mkEnableOption "gamedev";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      blender
      godot
      gimp
      krita
      inkscape
    ];
  };
}
