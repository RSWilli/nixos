# packages and config needed for my work environment
{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dbgate
    chromium
  ];
}
