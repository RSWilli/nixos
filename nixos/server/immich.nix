{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.immich;
in {
  options.my.server.immich = {
    enable = mkEnableOption "immich";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
    };
  };
}
