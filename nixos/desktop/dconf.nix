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

  favorite-apps = alwaysPinnedApps ++ cfg.pinned-apps;

  enabled-extensions = with pkgs.gnomeExtensions; [
    launch-new-instance # always launch a new instance of an app if the icon is clicked
    # user-themes # allows to change the shell theme
  ];

  dconf-settings = with lib.gvariant; {
    # TODO: easyeffects is dependent on the device names
    # "com/github/wwmm/easyeffects" = {
    #   last-used-input-preset = "Presets";
    #   last-used-output-preset = "Presets";
    #   process-all-inputs = true;
    #   process-all-outputs = false;
    #   window-fullscreen = false;
    #   window-height = 994;
    #   window-maximized = false;
    #   window-width = 835;
    # };

    # "com/github/wwmm/easyeffects/spectrum" = {
    #   color = mkTuple [1.0 1.0 1.0 1.0];
    #   color-axis-labels = mkTuple [1.0 1.0 1.0 1.0];
    # };

    # "com/github/wwmm/easyeffects/streaminputs" = {
    #   input-device = "alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.mono-fallback";
    #   plugins = ["stereo_tools#0" "rnnoise#0"];
    # };

    # "com/github/wwmm/easyeffects/streaminputs/deepfilternet/0" = {
    #   bypass = true;
    # };

    # "com/github/wwmm/easyeffects/streaminputs/rnnoise/0" = {
    #   enable-vad = false;
    # };

    # "com/github/wwmm/easyeffects/streaminputs/stereotools/0" = {
    #   bypass = false;
    #   mode = "LR > L+R (Mono Sum L+R)";
    # };

    # "com/github/wwmm/easyeffects/streamoutputs" = {
    #   output-device = "alsa_output.usb-1852_7022-01.analog-stereo";
    # };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${../../static/wallpaper.png}";
      picture-uri-dark = "file://${../../static/wallpaper.png}";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${../../static/wallpaper.png}";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-enable-primary-paste = false;
      gtk-theme = "Adwaita";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      disable-while-typing = false;
      speed = 0.734848;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      favorite-apps = favorite-apps;
      last-selected-power-profile = "power-saver";
      remember-mount-password = false;
      welcome-dialog-last-shown-version = "44.2";
      disable-user-extensions = false;
      enabled-extensions = map (ext: ext.extensionUuid) enabled-extensions;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "";
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = ["<Shift><Super>s"];
    };

    # "org/gnome/Weather" = {
    #   locations = [(mkVariant [(mkUint32 2) (mkVariant ["Leipzig" "EDDP" true [(mkTuple [0.8973901295515153 0.21351193934287546])] [(mkTuple [0.895353906273091 0.2152572685948698])]])])];
    # };

    # "org/gnome/shell/weather" = {
    #   automatic-location = true;
    #   locations = [(mkVariant [(mkUint32 2) (mkVariant ["Leipzig" "EDDP" true [(mkTuple [0.8973901295515153 0.21351193934287546])] [(mkTuple [0.895353906273091 0.2152572685948698])]])])];
    # };

    # "org/gnome/shell/world-clocks" = {
    #   locations = [(mkVariant [(mkUint32 2) (mkVariant ["Leipzig" "EDDP" true [(mkTuple [0.8973901295515153 0.21351193934287546])] [(mkTuple [0.895353906273091 0.2152572685948698])]])])];
    # };

    # TODO: this needs a dictonary and is not supported by dconf2nix
    # [org/gnome/clocks]
    # world-clocks=[{'location': <(uint32 2, <('Leipzig', 'EDDP', true, [(0.89739012955151531, 0.21351193934287546)], [(0.89535390627309097, 0.21525726859486979)])>)>}]

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    # Wellbeing
    "org/gnome/desktop/screen-time-limits" = {
      daily-limit-enabled = false;
    };

    "org/gnome/desktop/break-reminders" = {
      selected-breaks = ["eyesight" "movement"];
    };

    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = mkUint32 300;
      interval-seconds = mkUint32 1800;
      play-sound = true;
    };
  };
in {
  config = mkIf cfg.enable {
    programs.dconf = {
      enable = true;
      profiles = {
        # user is the name of the user profile
        user.databases = [
          {
            settings = dconf-settings;
          }
        ];
      };
    };

    environment.systemPackages = enabled-extensions;
  };
}
