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

    # the backup drive may be mounted with nofail. Without the mount the backups would
    # silently be written to the root filesystem, so fail instead.
    systemd.services = let
      requireBackupDir = enabled: mkIf enabled {unitConfig.RequiresMountsFor = [cfg.directory];};
    in {
      postgresqlBackup = requireBackupDir config.services.postgresql.enable;
      paperless-exporter = requireBackupDir config.services.paperless.exporter.enable;
      backup-vaultwarden = requireBackupDir (config.services.vaultwarden.backupDir != null);
    };

    # TODO: backup to external, e.g. with borg
  };
}
