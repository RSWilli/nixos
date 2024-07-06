{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.work;
in {
  options.my.work = {
    vpn = mkEnableOption "work vpn";
  };

  config = mkIf cfg.vpn {
    # user need to run
    # sudo tailscale up --accept-routes
    # to start using tailscale

    # make the tailscale command usable to users
    environment.systemPackages = [pkgs.tailscale];

    services.tailscale.useRoutingFeatures = "client";

    # enable the tailscale service
    services.tailscale.enable = true;
  };
}
