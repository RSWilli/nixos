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

  toToml = pkgs.formats.toml {};
  noctaliaConfigToml = toToml.generate "config.toml" {
    backdrop.enabled = true;
    wallpaper = {
      enabled = true;
      default.path = ../../static/wallpaper.jpg;
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
  };
in {
  options.my.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.custompackages.niri; # wrapped niri with included config
    };

    services.greetd.enable = true;
    programs.regreet = {
      enable = true;
      cageArgs = [ "-s" "-d" "-m" "last" ]; # only start cage on the last monitor
      settings = {
        # https://github.com/rharish101/ReGreet/blob/main/regreet.sample.toml
        skip_selection = true;
        background = {
          fit = "contain";
          path = ../../static/wallpaper.jpg;
        };
        appearance.greeting_msg = "Welcome back!";
      };
    };

    # wifi and bluetooth, required by noctalia
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;

    # power management, required by noctalia
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      material-cursors
      noctalia

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
      # tmpfiles below; keeping the path stable lets noctalia pick up config
      # reloads instead of requiring a new session on every rebuild.
      NOCTALIA_CONFIG_HOME = "/etc/noctalia";
      # make runtime changes to noctalia config temporary:
      NOCTALIA_STATE_HOME = "/tmp/noctalia-state";
    };

    nix.settings = {
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    environment.etc = {
      "noctalia/config.toml" = {
        source = noctaliaConfigToml;
      };
    };

    systemd.tmpfiles.rules = [
      # link the niri config to a fixed location:
      "L! /etc/niri/config.kdl - - - - ${pkgs.custompackages.niri}/niri-config.kdl"
    ];
  };
}
