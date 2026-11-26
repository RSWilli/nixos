# ssh access for remote maintenance (log in as root), only reachable via the netbird VPN
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.desktop.remoteMaintenance;
in {
  options.my.desktop.remoteMaintenance = {
    enable = mkEnableOption "ssh access via the netbird VPN";
  };

  config = mkIf cfg.enable {
    my.netbird.enable = true;

    services.openssh = {
      enable = true;
      openFirewall = false;
    };
    networking.firewall.interfaces.${config.services.netbird.clients.default.interface}.allowedTCPPorts = [22];
  };
}
