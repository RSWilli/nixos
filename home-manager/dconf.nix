# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = ["<Shift><Super>s"];
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${../static/wallpaper.png}";
      picture-uri-dark = "file://${../static/wallpaper.png}";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/interface" = {
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-theme = "Arc-Dark";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      disable-while-typing = false;
      speed = 0.734848;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${../static/wallpaper.png}";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/shell" = {
      enabled-extensions = ["launch-new-instance@gnome-shell-extensions.gcampax.github.com" "user-theme@gnome-shell-extensions.gcampax.github.com"];
      favorite-apps = ["firefox.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Console.desktop" "code.desktop" "org.telegram.desktop.desktop"];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "44.2";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Arc-Dark";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "com/github/wwmm/easyeffects" = {
      last-used-input-preset = "Presets";
      last-used-output-preset = "Presets";
      process-all-inputs = true;
      window-fullscreen = false;
      window-height = 994;
      window-maximized = false;
      window-width = 835;
    };

    "com/github/wwmm/easyeffects/spectrum" = {
      color = mkTuple [ 1.0 1.0 1.0 1.0 ];
      color-axis-labels = mkTuple [ 1.0 1.0 1.0 1.0 ];
    };

    "com/github/wwmm/easyeffects/streaminputs" = {
      # TODO: switch the input device per system
      input-device = "alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.mono-fallback";
      plugins = [ "stereo_tools#0" "rnnoise#0" ];
    };

    "com/github/wwmm/easyeffects/streaminputs/deepfilternet/0" = {
      bypass = true;
    };

    "com/github/wwmm/easyeffects/streaminputs/stereotools/0" = {
      bypass = false;
      mode = "LR > L+R (Mono Sum L+R)";
    };

    "com/github/wwmm/easyeffects/streamoutputs" = {
      # TODO: switch the output device per system
      output-device = "alsa_output.usb-FiiO_DigiHug_USB_Audio-01.iec958-stereo";
    };
  };
}
