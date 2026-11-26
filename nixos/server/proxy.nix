{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.server.proxy;

  squid = config.services.squid;
in {
  options.my.server.proxy = {
    enable = mkEnableOption "public http proxy with basic auth";
  };

  config = mkIf cfg.enable {
    # htpasswd file with the proxy users, create with `htpasswd -nB <user>`
    age.secrets.proxy-htpasswd = {
      file = ../../secrets/proxy-htpasswd.age;
      owner = "squid";
    };

    # lets external users appear to come from home (e.g. for YT Music family sharing).
    # basic auth is sent unencrypted to the proxy, the proxied https traffic itself stays encrypted
    services.squid = {
      enable = true;
      extraConfig = ''
        auth_param basic program ${squid.package}/libexec/basic_ncsa_auth ${config.age.secrets.proxy-htpasswd.path}
        auth_param basic realm proxy
        acl authenticated proxy_auth REQUIRED
        http_access allow authenticated
      '';
    };

    # port needs to be forwarded by the router
    networking.firewall.allowedTCPPorts = [squid.proxyPort];
  };
}
