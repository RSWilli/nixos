{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.paperless;
in {
  options.my.paperless = {
    enable = mkEnableOption "paperless";
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
    };
  };
}
