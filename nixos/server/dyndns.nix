# points the A/AAAA records of a domain (apex) to this host, using the Hetzner Cloud DNS API
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.dyndns;
in {
  options.my.server.dyndns = {
    enable = mkEnableOption "dynamic DNS updates via Hetzner";

    domain = mkOption {
      type = types.str;
      example = "example.com";
      description = "Hetzner DNS zone whose apex A/AAAA records are pointed to this host.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dyndns = {
      description = "Update ${cfg.domain} A/AAAA records";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      startAt = "*:0/5";
      path = [pkgs.curl pkgs.jq];
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        # HETZNER_API_TOKEN=..., the zone must be in the same Hetzner project as the ACME one
        EnvironmentFile = config.age.secrets.hetzner-dns.path;
      };
      script = ''
        set -eu
        api=https://api.hetzner.cloud/v1/zones/${cfg.domain}/rrsets
        auth=(-H "Authorization: Bearer $HETZNER_API_TOKEN" -H "Content-Type: application/json")

        set_record() {
          local records
          records=$(jq -nc --arg ip "$2" '[{value: $ip}]')
          # set_records only works on existing rrsets, create it on the first run
          curl --fail-with-body -sS "''${auth[@]}" -d "{\"records\":$records}" "$api/@/$1/actions/set_records" \
            || curl --fail-with-body -sS "''${auth[@]}" -d "{\"name\":\"@\",\"type\":\"$1\",\"ttl\":300,\"records\":$records}" "$api"
          echo
        }

        # public IPv4 of the router, IPv6 of this host (no temporary addresses, see wifi.nix)
        set_record A "$(curl -4 --fail -sS https://icanhazip.com)"
        set_record AAAA "$(curl -6 --fail -sS https://icanhazip.com)"
      '';
    };
  };
}
