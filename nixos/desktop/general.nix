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
    enableAutoLogin = mkEnableOption "auto login";

    pinned-apps = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = ''
        additional apps to pin to the dock
      '';
    };
  };

  config = mkIf (cfg.gnome.enable || cfg.cosmic.enable) {
    services.displayManager = {
      autoLogin = mkIf cfg.enableAutoLogin {
        enable = true;
        user = "willi";
      };
    };

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

    programs.firefox = {
      enable = true;
      wrapperConfig = {
        pipewireSupport = true;
      };
    };

    environment.systemPackages = with pkgs; [
      papers # pdf viewer

      baobab # GNOME disk usage analyzer

      pavucontrol
      qjackctl
      telegram-desktop
      vscode
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

    # autodiscover network printers and other devices
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    fonts.packages = with pkgs; [
      fira-code
    ];

    # enable cups for printing with some drivers
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };
  };
}
