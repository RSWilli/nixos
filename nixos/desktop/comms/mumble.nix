{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.communication;
in {
  options.my.desktop.communication = {
    mumble = mkEnableOption "mumble and its config";
  };

  config = mkIf cfg.mumble {
    environment.systemPackages = [
      pkgs.mumble
    ];

    my.desktop.pinned-apps = [
      "info.mumble.Mumble.desktop"
    ];

    # add mumble cert to home directory
    age.secrets."mumble-cert.p12" = {
      file = ../../../secrets/mumble-cert.age;
      path = "/home/willi/mumble-cert.p12";
      owner = "willi";
      mode = "600";
    };

    # add shortcut to mumble toggle mute key
    services.xserver.desktopManager.gnome = {
      extraGSettingsOverrides = ''
        [org/gnome/settings-daemon/plugins/media-keys]
        custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
        binding='KP_Add'
        command='mumble rpc togglemute '
        name='Mumble Toggle Mute'
      '';

      extraGSettingsOverridePackages = [pkgs.gnome-settings-daemon];
    };
  };
}
