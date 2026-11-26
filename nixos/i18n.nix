{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.i18n;
in {
  options.my.i18n = {
    language = mkOption {
      default = "en_US.UTF-8";
      example = "de_DE.UTF-8";
      type = types.str;
      description = ''
        system language (LANG). Formats (time, numbers, ...) are always german.
      '';
    };
  };

  config = {
    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = cfg.language;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    console.keyMap = "de";
    # keyboard layout for graphical sessions and the login screen
    services.xserver.xkb.layout = "de";
  };
}
