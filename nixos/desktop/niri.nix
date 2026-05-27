# https://wiki.nixos.org/wiki/Niri
# https://wiki.nixos.org/wiki/Greetd
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.niri;
in {
  options.my.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.custompackages.niri; # my wrapped niri
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.niri.package}/bin/niri-session";
          user = "willi";
        };
      };
    };
    programs.regreet.enable = true;

    # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
    # unit which shadows the imported user-manager PATH. Disabling the default
    # lets niri inherit the full PATH set up by niri-session.
    systemd.user.services.niri.enableDefaultPath = false;

    # wifi and bluetooth, required by noctalia
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;

    # power management, required by noctalia
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [ 
      alacritty

      seahorse # gnome keyring manager

      loupe # gnome image viewer
      showtime
      papers

      nirimod # graphical niri configuration editor
     ];
  };
}
