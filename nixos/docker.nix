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

      daemon.settings = {
        #  WIFIonICE vs Docker: Fixing DB (Deutsche Bahn) WIFI by moving Docker away from 172.18.x.x in /etc/docker/daemon.json
        # source: https://gist.github.com/sunsided/7840e89ff4e11b64a2d7503fafa0290c
        "bip" = "172.39.1.5/24";
        "fixed-cidr" = "172.39.1.0/25";
      };
    };

    users.users.willi.extraGroups = ["docker"];
  };
}
