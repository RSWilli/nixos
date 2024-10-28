{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
    lm_sensors # for the `sensors` command
  ];

  # enforce that all users are configured via this flake
  users.mutableUsers = false;

  zramSwap = {
    enable = true;
  };
}
