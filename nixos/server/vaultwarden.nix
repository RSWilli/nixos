{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server.vaultwarden;

  domain = "vault.${config.my.server.domain}";
  port = 8222;
in {
  options.my.server.vaultwarden = {
    enable = mkEnableOption "vaultwarden";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;

      backupDir = mkIf config.my.backup.enable "${config.my.backup.directory}/vaultwarden";

      config = {
        DOMAIN = "https://${domain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = port;

        # only reachable from inside the VPN. Disable once all accounts are created.
        SIGNUPS_ALLOWED = true;
      };
    };

    services.nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = config.my.server.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
