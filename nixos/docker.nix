{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.docker;
in {
  options.my.docker = {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;

      # automatically run a prune schedule
      autoPrune.enable = true;
    };

    users.users.willi.extraGroups = ["docker"];
  };
}
