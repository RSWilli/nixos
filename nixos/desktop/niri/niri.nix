# https://wiki.nixos.org/wiki/Niri
# https://wiki.nixos.org/wiki/Greetd
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.desktop.niri;

  toToml = pkgs.formats.toml {};

  wallpaper = ../../../static/wallpaper.jpg;

  noctaliaConfigToml = toToml.generate "config.toml" {
    backdrop.enabled = true;
    wallpaper = {
      enabled = true;
      default.path = wallpaper;
    };

    bar = {
      default = {
        capsule = true;
        margin_edge = 0;
        margin_ends = 0;
        radius = 0;
        shadow = false;
        start = [
          "launcher"
          "workspaces"
        ];
      };
    };
    widget.control-center = {
      glyph = "adjustments-horizontal";
    };
    widget.bluetooth = {
      show_label = true;
    };
    desktop_widgets = {
      enabled = false;
    };
    idle = {
      behavior = {
        lock = {
          action = "lock";
          enabled = true;
          timeout = 600;
        };
        lock-and-suspend = {
          action = "lock_and_suspend";
          enabled = false;
          timeout = 900;
        };
        screen-off = {
          action = "screen_off";
          enabled = true;
          timeout = 660;
        };
      };
      behavior_order = [
        "lock"
        "screen-off"
        "lock-and-suspend"
      ];
    };
    location = {
      address = "Leipzig, Germany";
    };
    theme = {
      mode = "light";
      source = "wallpaper";
      wallpaper_scheme = "vibrant";
    };
    osd.kinds.media = false; # no notification for playing media

    # the first-run setup wizard writes noctalia's bundled wallpaper into the
    # state overrides, which then shadow the wallpaper declared above. Nothing
    # it asks for is left undeclared here, so skip it.
    shell.setup_wizard_enabled = false;
  };
in {
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  options.my.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };

    programs.noctalia-greeter = {
      enable = true;
      package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;

      # Optional configuration
      # https://docs.noctalia.dev/greeter/configuration/
      greeter-args = "";
      settings = {
        session.default = "niri";

        appearance = {
          # "Synced" is the slot the palette below occupies; a complete
          # [appearance.palette] here wins over whatever sync.toml holds, so the
          # greeter theme stays declarative instead of depending on the shell's
          # "Sync Now" button.
          scheme = "Synced";
          theme_mode = "light"; # matches theme.mode above

          # Run the following command to generate a palette from the wallpaper:
          #   noctalia theme static/wallpaper.jpg --scheme vibrant --light
          palette = {
            primary = "#5c700f";
            on_primary = "#fafaf9";
            secondary = "#26630d";
            on_secondary = "#fafafa";
            tertiary = "#15624b";
            on_tertiary = "#fbfbfa";
            error = "#fd4663";
            on_error = "#fafaf9";
            surface = "#f1f9d2";
            on_surface = "#1a1b18";
            surface_variant = "#e0f29c";
            on_surface_variant = "#5c5e55";
            outline = "#86944f";
            shadow = "#d3d8c0";
            hover = "#e8f5b8";
            on_hover = "#1a1b18";
          };

          wallpaper = {
            path = "${wallpaper}";
            fill_mode = "crop"; # noctalia's default
          };
        };

        cursor = {
          theme = "Adwaita";
          size = 24;
          path = "${pkgs.adwaita-icon-theme}/share/icons";
        };
      };
    };

    # wifi and bluetooth, required by noctalia
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;
    hardware.bluetooth.enable = true;

    # power management, required by noctalia
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      noctalia
      xwayland-satellite

      alacritty

      seahorse # gnome keyring manager

      loupe # gnome image viewer
      showtime
      decibels
      papers

      nautilus # file manager

      nirimod # graphical niri configuration editor
    ];

    environment.sessionVariables = {
      # point at a fixed location whose config is symlinked into the store via
      # environment.etc below; keeping the path stable lets noctalia pick up
      # config reloads instead of requiring a new session on every rebuild.
      NOCTALIA_CONFIG_HOME = "/etc/noctalia";
      # make runtime changes to noctalia config temporary:
      NOCTALIA_STATE_HOME = "/tmp/noctalia-state";

      NIRI_CONFIG = "/etc/niri/config.kdl";
    };

    environment.etc = {
      # noctalia appends "/noctalia" to NOCTALIA_CONFIG_HOME itself, so the config
      # dir it actually reads is /etc/noctalia/noctalia.
      "noctalia/noctalia/config.toml" = {
        source = noctaliaConfigToml;
      };
      "niri/config.kdl" = {
        source = ./config.kdl;
      };
    };
  };
}
