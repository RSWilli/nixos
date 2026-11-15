{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.immich;

  domain = "immich.${config.my.server.domain}";
in {
  options.my.server.immich = {
    enable = mkEnableOption "immich";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
    };

    services.nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = config.my.server.domain;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.immich.port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
      };
    };
  };
}
