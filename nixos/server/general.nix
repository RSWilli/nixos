{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server;

  vpnInterface = config.services.netbird.clients.default.interface;
in {
  options.my.server = {
    enable = mkEnableOption "server";

    domain = mkOption {
      type = types.str;
      example = "home.example.com";
      description = ''
        Domain of this server. Services are reachable as <service>.<domain> from inside the VPN,
        public services (teamspeak) as ts.<domain>.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.openssh.enable = true;

    services.fail2ban.enable = true;

    my.netbird.enable = true;

    # contains HETZNER_API_TOKEN=..., used for ACME DNS-01
    age.secrets.hetzner-dns.file = ../../secrets/hetzner-dns.age;

    # wildcard cert for all services, works without exposing anything publicly
    security.acme = {
      acceptTerms = true;
      # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # use staging letsencrypt, for testing
      defaults.dnsResolver = "1.1.1.1:53"; # don't use netbird's resolver
      certs.${cfg.domain} = {
        domain = "*.${cfg.domain}";
        dnsProvider = "hetzner";
        environmentFile = config.age.secrets.hetzner-dns.path;
        group = config.services.nginx.group;
      };
    };

    # reverse proxy for the services, every service module adds its own virtualHost
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
    };

    # https is only reachable from inside the VPN
    networking.firewall.interfaces.${vpnInterface}.allowedTCPPorts = [443];
  };
}
