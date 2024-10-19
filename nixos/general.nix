{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
  ];

  zramSwap = {
    enable = true;
  };
}
