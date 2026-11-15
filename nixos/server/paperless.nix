{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server.paperless;

  domain = "paperless.${config.my.server.domain}";
in {
  options.my.server.paperless = {
    enable = mkEnableOption "paperless";
  };

  config = mkIf cfg.enable {
    age.secrets.paperless-admin.file = ../../secrets/paperless-admin.age;

    services.paperless = {
      enable = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";

        PAPERLESS_ADMIN_USER = "rswilli";

        PAPERLESS_URL = "https://${domain}";
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

    services.nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = config.my.server.domain;
      locations."/" = {
        proxyPass = "http://${config.services.paperless.address}:${toString config.services.paperless.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100M;
        '';
      };
    };
  };
}
