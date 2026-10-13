{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.users;
in {
  options.my.users = {
    lara = {
      enable = mkEnableOption "enable lara user";
    };
  };

  config = mkIf cfg.lara.enable {

    age.secrets.password.file = ../../secrets/password.age;

    users.users = {
      lara = {
        isNormalUser = true;
        description = "Lara";
        extraGroups = [
          "audio"
          "avahi"
          "networkmanager"
          "render"
          "video"
        ];

        hashedPasswordFile = config.age.secrets.password.path;
      };
    };
  };
}
