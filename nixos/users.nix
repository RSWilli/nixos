{config, ...}: {
  imports = [];

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
        source = ../static/willi-id_ed25519.pub;
        target = ".ssh/id_ed25519.pub";
      };

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      home.stateVersion = "23.05";
    };
  };

  # enforce that all users are configured via this flake
  users.mutableUsers = false;

  users.users = {
    root = {
      hashedPasswordFile = config.age.secrets.root-password.path;
      #   openssh.authorizedKeys.keys = [
      #     # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      #   ];
    };
    willi = {
      isNormalUser = true;
      description = "Wilhelm Bartel";
      extraGroups = ["networkmanager" "wheel"];
      hashedPasswordFile = config.age.secrets.password.path;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
    };
  };

  # setup ssh keys
  age.secrets."id_ed25519" = {
    file = ../secrets/willi-id_ed25519.age;
    path = "/home/willi/.ssh/id_ed25519";
    owner = "willi";
    mode = "600";
  };
}
