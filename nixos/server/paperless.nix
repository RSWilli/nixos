{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server.paperless;
in {
  options.my.server.paperless = {
    enable = mkEnableOption "paperless";
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";

        PAPERLESS_ADMIN_USER = "rswilli";
      };

      passwordFile = config.age.secrets.paperless-admin.path;

      # configureNginx = true;
      # domain = "example.com";

      exporter = {
        enable = config.my.backup.enable;
        directory = "${config.my.backup.directory}/paperless";
      };

      database.createLocally = true;
    };
  };
}
