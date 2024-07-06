{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.communication;
in {
  options.my.communication = {
    matrix = mkEnableOption "matrix";
    discord = mkEnableOption "discord";
    teamspeak = mkEnableOption "teamspeak";
  };

  config = mkMerge [
    (
      mkIf cfg.matrix {
        environment.systemPackages = [
          pkgs.element-desktop
        ];
      }
    )
    (
      mkIf cfg.discord {
        environment.systemPackages = [
          pkgs.discord
        ];
      }
    )
    (
      mkIf cfg.teamspeak {
        environment.systemPackages = [
          pkgs.teamspeak_client
        ];
      }
    )
  ];
}
