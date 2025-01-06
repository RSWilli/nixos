{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.my.users;
in {
  options.my.users = {
    willi = {
      enable = mkEnableOption "enable willi user";
    };
  };

  config = mkIf cfg.willi.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.willi = {
        home = {
          username = "willi";
          homeDirectory = "/home/willi";
        };

        # setup public ssh key:
        home.file.publickey = {
          text = lib.my.publicKey;
          target = ".ssh/id_ed25519.pub";
        };

        # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
        home.stateVersion = "23.05";
      };
    };

    users.users = {
      willi = {
        isNormalUser = true;
        description = "Wilhelm Bartel";
        extraGroups = [
          "audio"
          "avahi"
          "networkmanager"
          "render"
          "video"
          "wheel"
        ];
        hashedPasswordFile = config.age.secrets.password.path;
        openssh.authorizedKeys.keys = [
          lib.my.publicKey
        ];
      };
    };

    # setup ssh keys
    age.secrets."id_ed25519" = {
      file = ../../secrets/willi-id_ed25519.age;
      path = "/home/willi/.ssh/id_ed25519";
      owner = "willi";
      mode = "600";
    };
  };
}
