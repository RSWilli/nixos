{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;
in {
  options.my.desktop = {
    steam = mkEnableOption "steam";
  };

  config = mkIf cfg.steam {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers

      gamescopeSession.enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
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
