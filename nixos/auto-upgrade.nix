{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.autoUpgrade;
in {
  options.my.autoUpgrade = {
    enable = mkEnableOption "auto upgrade system";
  };

  config = mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake = "github:RSWilli/nixos";
      flags = ["--refresh"];
      dates = "04:00";
      randomizedDelaySec = "45min";
      persistent = true;
      allowReboot = false;
      operation = "boot";
    };
  };
}
