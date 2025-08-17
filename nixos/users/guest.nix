{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.users;
in {
  options.my.users = {
    guest = {
      enable = mkEnableOption "enable guest user";
    };
  };

  config = mkIf cfg.guest.enable {
    users.users = {
      guest = {
        isNormalUser = true;
        description = "Guest user";
        extraGroups = [
          "audio"
          "avahi"
          "networkmanager"
          "render"
          "video"
        ];

        initialPassword = "guest";
      };
    };
  };
}
