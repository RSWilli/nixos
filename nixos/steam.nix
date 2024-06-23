{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };

  environment.systemPackages = [
    pkgs.r2modman
    pkgs.mangohud
  ];

  programs.gamemode.enable = true;

  my.pinned-apps = [
    "steam.desktop"
  ];
}
