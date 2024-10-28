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
    my.server.postgresql = {
      enable = true;
      ensureDatabases = ["paperless"];
    };

    my.server.reverseproxy_targets = {
      "paperless.w-bartel.de" = config.services.paperless.port;
    };

    services.paperless = {
      enable = true;
      settings = {
        PAPERLESS_DB_NAME = "paperless";
        PAPERLESS_DB_HOST = "/run/postgresql";

        PAPERLESS_OCR_LANGUAGE = "deu+eng";
      };
    };
  };
}
