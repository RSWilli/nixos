# packages and config needed for my work environment
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dbgate
    chromium
  ];
}
