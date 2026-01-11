{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.communication;
in {
  options.my.desktop.communication = {
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
    # qtwebengine-5.15.19 is marked as insecure (see https://github.com/NixOS/nixpkgs/issues/440030) and needs upstream fixes
    # or nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ]; to be used
    # (
    #   mkIf cfg.teamspeak {
    #     environment.systemPackages = [
    #       pkgs.teamspeak_client
    #     ];
    #   }
    # )
  ];
}
