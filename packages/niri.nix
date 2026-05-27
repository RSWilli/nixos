# Wrapper package for niri, containing all settings and configuration. Also see noctalia-shell.nix.
#
# See: https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/niri.html
#
# niri default config: https://github.com/niri-wm/niri/blob/main/resources/default-config.kdl
{
  lib,
  pkgs,
  niriWrapper,
  custompackages,
}:
niriWrapper {
  inherit pkgs;
  v2-settings = true;

  settings = {
    spawn-at-startup = [
      (lib.getExe custompackages.noctalia-shell)
    ];

    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

    input.keyboard.xkb.layout = "de";

    layout.gaps = 5;

    # binds = {
    # "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
    # "Mod+Q".close-window = null;
    # "Mod+Space".spawn-sh = "${lib.getExe custompackages.noctalia-shell} ipc call launcher toggle";
    # };

  #   binds {
  #     // Core Noctalia binds
  #     Mod+Space { spawn-sh "qs -c noctalia-shell ipc call launcher toggle"; }
  #     Mod+S { spawn-sh "qs -c noctalia-shell ipc call controlCenter toggle"; }
  #     Mod+Comma { spawn-sh "qs -c noctalia-shell ipc call settings toggle"; }

  #     // Audio & Brightness
  #     XF86AudioRaiseVolume { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "increase"; }
  #     XF86AudioLowerVolume { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "decrease"; }
  #     XF86AudioMute { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
  #     XF86MonBrightnessUp { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "brightness" "increase"; }
  #     XF86MonBrightnessDown { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "brightness" "decrease"; }
  # }
  };
}
