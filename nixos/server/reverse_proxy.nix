{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server;
in {
  options.my.server.reverseproxy_targets = mkOption {
    type = types.attrsOf types.int;
    default = {};
    description = "Reverse proxy targets, mapping servername to local port";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.nginx = {
      enable = true;

      # Use recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Only allow PFS-enabled ciphers with AES256
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      appendHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';

      virtualHosts = let
        base = locations: {
          inherit locations;

          forceSSL = true;
          enableACME = true;
        };
        proxy = port:
          base {
            "/".proxyPass = "http://127.0.0.1:" + toString port + "/";
          };
      in
        (lib.mapAttrs (servername: port: proxy port) cfg.reverseproxy_targets)
        // {
          "default" = {
            default = true;
            # never answer to requests for the default server
            locations = {
              "/" = {
                return = "444";
              };
            };
          };
        };
    };

    # let's encrypt settings:
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "bartel.wilhelm@gmail.com";

        # use staging environment, see https://letsencrypt.org/docs/staging-environment/
        server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      };
    };
  };
}
