{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.my.desktop;
in

{
  options.my.desktop = {
    steam = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
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

  my.desktop.pinned-apps = [
    "steam.desktop"
  ];
  };
}
