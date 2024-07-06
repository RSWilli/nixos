{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [];

  options = {
    my.pinned-apps = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = ''
        additional apps to pin to the dock
      '';
    };
  };

  config = let
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
          favorite-apps=[ ${toDconfPinnedApps (alwaysPinnedApps ++ config.my.pinned-apps)} ]
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
          picture-uri='file://${../static/wallpaper.png}'
          primary-color='#000000000000'
          secondary-color='#000000000000'

          [org/gnome/desktop/background]
          color-shading-type='solid'
          picture-options='zoom'
          picture-uri='file://${../static/wallpaper.png}'
          picture-uri-dark='file://${../static/wallpaper.png}'
          primary-color='#000000000000'
          secondary-color='#000000000000'
        '';

        extraGSettingsOverridePackages = with pkgs.gnome; [
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
    sound.enable = true;
    hardware.pulseaudio.enable = false;
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
      easyeffects
      # gnome3.gpaste currently broken, see https://github.com/NixOS/nixpkgs/issues/92265
      arc-theme
      firefox
      gnome.adwaita-icon-theme
      gnome.gnome-tweaks
      pavucontrol
      qjackctl
      telegram-desktop
      mpv
      vscode
    ];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gnome-connections
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gnome-maps
        #gnome-terminal
        #gedit # text editor
        #epiphany # web browser
        geary # email reader
        evince # document viewer
        #gnome-characters
        totem # video player
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ]);

    services.gnome = {
      games.enable = false;
    };

    programs.dconf.enable = true;

    fonts.packages = with pkgs; [
      fira-code
    ];
  };
}
