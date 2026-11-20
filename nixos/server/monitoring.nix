{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.monitoring;

  domain = "grafana.${config.my.server.domain}";

  # maps the Gen1 Shelly Plug S /status endpoint to prometheus metrics
  jsonExporterConfig = pkgs.writeText "json-exporter.yaml" (builtins.toJSON {
    modules.shelly.metrics = [
      {
        name = "shelly_power_watts";
        path = "{ .meters[0].power }";
      }
      {
        # Gen1 counts in watt-minutes and resets on plug reboot, use increase() on it
        name = "shelly_energy_watt_minutes_total";
        path = "{ .meters[0].total }";
        valuetype = "counter";
      }
      {
        name = "shelly_temperature_celsius";
        path = "{ .temperature }";
      }
      {
        name = "shelly_wifi_rssi_dbm";
        path = "{ .wifi_sta.rssi }";
      }
    ];
  });
in {
  options.my.server.monitoring = {
    enable = mkEnableOption "host and power monitoring with prometheus and grafana";

    shellyAddress = mkOption {
      type = types.str;
      example = "192.168.178.61";
      description = "Address of the Gen1 Shelly Plug S that powers this host, its login must not be restricted.";
    };
  };

  config = mkIf cfg.enable {
    age.secrets = {
      grafana-admin = {
        file = ../../secrets/grafana-admin.age;
        owner = "grafana";
      };
      grafana-secret-key = {
        file = ../../secrets/grafana-secret-key.age;
        owner = "grafana";
      };
    };

    services.prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      retentionTime = "1y";

      globalConfig.scrape_interval = "15s";

      exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = ["systemd" "wifi"];
      };

      exporters.json = {
        enable = true;
        listenAddress = "127.0.0.1";
        configFile = jsonExporterConfig;
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
              labels.instance = config.networking.hostName;
            }
          ];
        }
        {
          # json_exporter fetches the url given as target parameter
          job_name = "shelly";
          metrics_path = "/probe";
          params = {
            module = ["shelly"];
            target = ["http://${cfg.shellyAddress}/status"];
          };
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.json.port}"];
              labels.instance = "shelly-${config.networking.hostName}";
            }
          ];
        }
      ];
    };

    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          inherit domain;
          root_url = "https://${domain}/";
        };

        security = {
          admin_user = "rswilli";
          # only used when the database is created on first start
          admin_password = "$__file{${config.age.secrets.grafana-admin.path}}";
          secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
          cookie_secure = true;
        };

        # managed by nix
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
          check_for_plugin_updates = false;
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];

        # edit in grafana, export as JSON and replace the file
        dashboards.settings.providers = [
          {
            name = "homelab";
            options.path = ./grafana-dashboards;
          }
        ];
      };
    };

    services.nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = config.my.server.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
      };
    };
  };
}
