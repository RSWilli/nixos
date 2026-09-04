{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.backup;
in {
  options.my.backup = {
    enable = mkEnableOption "backup";

    directory = mkOption {
      default = "/var/backup";
      type = types.path;
      description = ''
        Path of the backup directory
      '';
    };
  };

  config = mkIf cfg.enable {
    services.postgresqlBackup = mkIf config.services.postgresql.enable {
      enable = true;
      location = "${cfg.directory}/postgresql";
    };

    # TODO: backup to external, e.g. with borg
  };
}
