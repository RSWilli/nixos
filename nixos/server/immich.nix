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

      # Only values that differ from the immich defaults, see
      # https://github.com/immich-app/immich/blob/main/server/src/dtos/config.dto.ts
      # Setting this locks the settings in the web UI.
      settings = {
        # default: ViT-B-32__openai see https://docs.immich.app/features/searching/
        # 1GB RAM, 5.77ms, 75.21% german recall, pareto optimal
        machineLearning.clip.modelName = "ViT-B-16-SigLIP__webli";

        # default: false, default template: {{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}
        storageTemplate.enabled = true;

        server.externalDomain = "https://${domain}";
      };
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
