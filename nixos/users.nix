{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.willi = lib.mkMerge [
      ../home-manager/home.nix
      {
        # setup public ssh key:
        home.file.publickey = {
          source = ../static/willi-id_ed25519.pub;
          target = ".ssh/id_ed25519.pub";
        };
      }
    ];
  };

  programs.zsh.enable = true;
  environment.shells = with pkgs; [
    zsh
  ];

  # enforce that all users are configured via this flake
  users.mutableUsers = false;

  users.users = {
    root = {
      shell = pkgs.zsh;
      hashedPasswordFile = config.age.secrets.root-password.path;
      #   openssh.authorizedKeys.keys = [
      #     # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      #   ];
    };
    willi = {
      isNormalUser = true;
      description = "Wilhelm Bartel";
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;
      hashedPasswordFile = config.age.secrets.password.path;
      packages = with pkgs; [
        firefox
        telegram-desktop
        gnome.adwaita-icon-theme
        gnome.gnome-tweaks
        arc-theme
        # gnome3.gpaste currently broken, see https://github.com/NixOS/nixpkgs/issues/92265

        # language server for nix:
        nil
        nixpkgs-fmt
      ];
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
