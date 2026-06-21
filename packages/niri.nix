# Wrapper package for niri, containing all settings and configuration.
#
# See: https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/niri.html
#
# and https://niri-wm.github.io/niri/Configuration:-Input (or https://github.com/niri-wm/niri/wiki)
#
# niri default config: https://github.com/niri-wm/niri/blob/main/resources/default-config.kdl
{
  lib,
  pkgs,
  niriWrapper,
  noctalia,
  material-cursors,
  mumble,
}: let
  noctaliaExe = lib.getExe noctalia;
  noValue = _: {}; # wrapper config kdl value for value-less keys
in
  niriWrapper {
    inherit pkgs;

    runtimePkgs = [
      material-cursors
    ];

    v2-settings = true;

    settings = {
      spawn-at-startup = [
        noctaliaExe
        # maybe wallpaper with swaybg instead of noctalia-shell:
        # (lib.getExe (
        #   pkgs.writeShellScriptBin "wallpaper"
        #   "${lib.getExe pkgs.swaybg} -i ${self.wallpaper} -m fill"
        # ))
      ];

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      # see https://niri-wm.github.io/niri/Configuration:-Input
      input = {
        keyboard.xkb.layout = "de";
        touchpad = {
          accel-profile = "flat";
          accel-speed = 0.734848;
          tap = noValue;
          natural-scroll = noValue;
        };
        mouse = {
          accel-profile = "flat";
          # accel-speed = 0.734848;
        };

        # Uncomment this to make the mouse warp to the center of newly focused windows.
        # warp-mouse-to-focus

        # Focus windows and outputs automatically when moving the mouse into them.
        # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
        # focus-follows-mouse max-scroll-amount="0%"
      };

      # see https://niri-wm.github.io/niri/Configuration:-Outputs
      outputs = {
        eDP-1 = {
          # laptop internal display
          # mode = "1920x1080";
        };

        "Acer Technologies VG270U P 0x847015D0" = {
          # home main left
          mode = "2560x1440@143.999";
          scale = 1.0;
          transform = "normal";
          position = _: {
            props = {
              x = 0;
              y = 0;
            };
          };
          # variable-refresh-rate = noValue;
        };

        "Acer Technologies VG270U P 0x91704B66" = {
          # home main right
          mode = "2560x1440@143.999";
          scale = 1.0;
          transform = "normal";
          position = _: {
            props = {
              x = 2560;
              y = 0;
            };
          };
          # variable-refresh-rate = noValue;
        };
      };

      # see https://niri-wm.github.io/niri/Configuration:-Layout
      layout = {
        gaps = 16;
        preset-column-widths = [
          {proportion = 0.33333;}
          {proportion = 0.5;}
          {proportion = 0.66667;}
        ];

        default-column-width.proportion = 0.5;

        focus-ring = {
          width = 4;
          active-color = "#7fc8ff";
          inactive-color = "#505050";
        };
      };

      # hotkey-overlay.skip-at-startup = noValue; # don't show the hotkey overlay at startup

      # prefer-no-csd = noValue; # prefer non-client-side-decorations (title bars) when available

      screenshot-path = null; # disabled, we screenshot via hotkey script

      # see https://niri-wm.github.io/niri/Configuration:-Animations
      animations = {};

      # see https://niri-wm.github.io/niri/Configuration:-Window-Rules
      window-rules = [];

      # see https://niri-wm.github.io/niri/Configuration:-Layer-Rules.html
      layer-rules = [
        # Set the overview wallpaper on the backdrop, from https://docs.noctalia.dev/v4/getting-started/compositor-settings/niri/#option-1-blurred-overview-wallpaper
        {
          matches = [
            {namespace = "^noctalia-backdrop";}
          ];
          place-within-backdrop = true;
        }
      ];

      cursor = {
        xcursor-theme = "material-cursors";
        xcursor-size = 48;
      };

      # use `wev` to find the key syms
      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = noValue;
        "Mod+Q" = _: {
          props.repeat = false;
          content.close-window = noValue;
        };

        "Mod+O" = _: {
          props.repeat = false;
          content.toggle-overview = noValue;
        };

        "Mod+Space".spawn-sh = "${noctaliaExe} msg panel-toggle launcher";
        "Mod+S".spawn-sh = "${noctaliaExe} msg panel-toggle control-center";
        "Mod+Comma".spawn-sh = "${noctaliaExe} msg settings-toggle";

        # Audio & Brightness
        "XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          content.spawn-sh = "${noctaliaExe} msg volume-up";
        };
        "XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn-sh = "${noctaliaExe} msg volume-down";
        };
        "XF86AudioMute" = _: {
          props.allow-when-locked = true;
          content.spawn-sh = "${noctaliaExe} msg volume-mute";
        };
        "XF86MonBrightnessUp" = _: {
          props.allow-when-locked = true;
          content.spawn-sh = "${noctaliaExe} msg brightness-up";
        };
        "XF86MonBrightnessDown" = _: {
          props.allow-when-locked = true;
          content.spawn-sh = "${noctaliaExe} msg brightness-down";
        };

        "Mod+L".spawn-sh = "${noctaliaExe} msg lock";

        # TODO: use a custom screenshot script that pipes into satty so we can edit the screenshot
        "Mod+Shift+S".spawn-sh = "${noctaliaExe} msg screenshot-region";

        "Mod+Left".focus-column-left = noValue;
        "Mod+Down".focus-window-down = noValue;
        "Mod+Up".focus-window-up = noValue;
        "Mod+Right".focus-column-right = noValue;

        "Mod+Ctrl+Left".move-column-left = noValue;
        "Mod+Ctrl+Down".move-window-down = noValue;
        "Mod+Ctrl+Up".move-window-up = noValue;
        "Mod+Ctrl+Right".move-column-right = noValue;

        "Mod+Home".focus-column-first = noValue;
        "Mod+End".focus-column-last = noValue;
        "Mod+Ctrl+Home".move-column-to-first = noValue;
        "Mod+Ctrl+End".move-column-to-last = noValue;

        "Mod+Shift+Left".focus-monitor-left = noValue;
        "Mod+Shift+Right".focus-monitor-right = noValue;
        "Mod+Shift+Up".focus-monitor-up = noValue;
        "Mod+Shift+Down".focus-monitor-down = noValue;

        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = noValue;
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = noValue;
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = noValue;
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = noValue;

        "Mod+Page_Down".focus-workspace-down = noValue;
        "Mod+Page_Up".focus-workspace-up = noValue;
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = noValue;
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = noValue;

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

        # Fill the whole screen, but leave the bar visible:
        "Mod+F".maximize-window-to-edges = noValue;
        # fullscreen, hides the bar:
        "Mod+Shift+F".fullscreen-window = noValue;

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Plus".set-column-width = "+10%";

        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Plus".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = noValue;
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = noValue;

        "Print".screenshot = noValue;
        "Ctrl+Print".screenshot-screen = noValue;
        "Alt+Print".screenshot-window = noValue;

        "Mod+Escape" = _: {
          props.allow-inhibiting = false;
          content.toggle-keyboard-shortcuts-inhibit = noValue;
        };

        "Ctrl+Alt+Delete".quit = noValue;

        # mumble keybinds:
        "MouseForward".spawn-sh = "${lib.getExe mumble} rpc togglemute";
        "MouseBack".spawn-sh = "${lib.getExe mumble} rpc toggledeaf";
      };

      debug.honor-xdg-activation-with-invalid-serial = noValue; # recommended by noctalia-shell
    };
  }
