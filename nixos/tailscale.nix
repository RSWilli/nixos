{pkgs, ...}: {
  # user need to run
  # sudo tailscale up --accept-routes
  # to start using tailscale

  # make the tailscale command usable to users
  environment.systemPackages = [pkgs.tailscale];

  services.tailscale.useRoutingFeatures = "client";

  # enable the tailscale service
  services.tailscale.enable = true;
}
