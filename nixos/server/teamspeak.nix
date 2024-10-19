{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server.teamspeak;
in {
  options.my.server.teamspeak = {
    enable = mkEnableOption "teamspeak";
  };

  config = mkIf cfg.enable {
    services.teamspeak3 = {
      enable = true;
      openFirewall = true;
    };
  };
}
