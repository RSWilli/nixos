# packages and config needed for my work environment
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.work;
in {
  options.my.work = {
    apps = mkEnableOption "Work Apps";
  };

  config = mkIf cfg.apps {
    environment.systemPackages = with pkgs; [
      dbgate
      chromium
      dig
    ];
  };
}
