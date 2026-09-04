{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server;
in {
  options.my.server = {
    enable = mkEnableOption "server";
  };

  config = mkIf cfg.enable {
    services.openssh.enable = true;

    services.fail2ban.enable = true;
  };
}
