{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop;

  alwaysPinnedApps = [
    "firefox.desktop"
    "org.gnome.Nautilus.desktop"
    "org.gnome.Console.desktop"
    "code.desktop"
    "org.telegram.desktop.desktop"
  ];

  # correctly quote and concat the apps
  toDconfPinnedApps = apps: lib.strings.concatStringsSep ", " (lib.lists.imap0 (i: app: "'${app}'") apps);
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
      displayManager.gdm.enable = true;
      desktopManager.gnome = {
        enable = true;
        favoriteAppsOverride = ''
          [org.gnome.shell]
          favorite-apps=[ ${toDconfPinnedApps (alwaysPinnedApps ++ cfg.pinned-apps)} ]
        '';

        extraGSettingsOverrides = ''
          [org/gnome/shell/keybindings]
          show-screenshot-ui=['<Shift><Super>s']

          [org/gnome/shell]
          enabled-extensions=['launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']

          [org/gnome/mutter]
          dynamic-workspaces=true
          edge-tiling=true
          workspaces-only-on-primary=true

          [org/gnome/desktop/wm/preferences]
          button-layout='appmenu:minimize,maximize,close'

          [org/gnome/desktop/peripherals/touchpad]
          click-method='areas'
          disable-while-typing=false
          speed=0.734848
          tap-to-click=true
          two-finger-scrolling-enabled=true

          [org/gnome/desktop/interface]
          gtk-theme='Arc-Dark'
          show-battery-percentage=true

          [org/gnome/shell/extensions/user-theme]
          name='Arc-Dark'

          [org/gnome/desktop/screensaver]
          color-shading-type='solid'
          picture-options='zoom'
          picture-uri='file://${../../static/wallpaper.png}'
          primary-color='#000000000000'
          secondary-color='#000000000000'

          [org/gnome/desktop/background]
          color-shading-type='solid'
          picture-options='zoom'
          picture-uri='file://${../../static/wallpaper.png}'
          picture-uri-dark='file://${../../static/wallpaper.png}'
          primary-color='#000000000000'
          secondary-color='#000000000000'
        '';

        extraGSettingsOverridePackages = with pkgs; [
          gnome-settings-daemon
          gnome-session
          gnome-shell
        ];
      };
    };

    services.displayManager = {
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
      mpv
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
      totem # video player
      yelp # Help view
    ];

    services.gnome = {
      games.enable = false;
    };

    programs.dconf.enable = true;

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
