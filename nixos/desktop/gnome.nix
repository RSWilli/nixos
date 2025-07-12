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
    enable = mkEnableOption "desktop";

    pinned-apps = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = ''
        additional apps to pin to the dock
      '';
    };
  };
  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "de";
        variant = "";
      };
    };

    services.desktopManager.gnome.enable = true;

    services.displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = "willi";
      };
    };

    services.printing.enable = true; # cups

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    environment.systemPackages = with pkgs; [
      # gnome3.gpaste currently broken, see https://github.com/NixOS/nixpkgs/issues/92265
      adwaita-icon-theme
      arc-theme
      easyeffects
      firefox
      gnome-tweaks

      totem # video player
      decibels # audio player

      pavucontrol
      qjackctl
      telegram-desktop
      vscode
    ];

    environment.gnome.excludePackages = with pkgs; [
      #epiphany # web browser
      #gedit # text editor
      #gnome-characters
      #gnome-terminal
      cheese # webcam tool
      # evince # document viewer
      geary # email reader
      gnome-connections
      gnome-contacts
      gnome-initial-setup
      gnome-maps
      gnome-music
      gnome-photos
      gnome-tour
      yelp # Help view
    ];

    services.gnome = {
      games.enable = false;
    };

    fonts.packages = with pkgs; [
      fira-code
    ];

    # Ozone Wayland support in Chrome and several Electron apps (needed for vscode to render in Wayland)
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # hardware acceleration for graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
