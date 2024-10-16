{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
  ];

  zramSwap = {
    enable = true;
  };

  # hardware acceleration for graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
