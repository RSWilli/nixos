{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop.amd = mkEnableOption "amd";

  config = mkIf cfg.amd {
    hardware.graphics.extraPackages = [
      # this causes black boxes https://gitlab.gnome.org/GNOME/gtk/-/issues/6890 , re-enable when fixed
      # pkgs.amdvlk
    ];
  };
}
