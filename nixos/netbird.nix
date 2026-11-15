# netbird VPN client, using the hosted control plane at app.netbird.io
#
# needs a one time login per machine:
#   sudo netbird up
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.netbird;
in {
  options.my.netbird = {
    enable = mkEnableOption "netbird VPN client";
  };

  config = mkIf cfg.enable {
    # creates the client "default" with interface wt0
    services.netbird.enable = true;
  };
}
