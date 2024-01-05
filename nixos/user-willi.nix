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
        programs.ssh = {
          enable = true;
          includes = [
            config.age.secrets."id_ed25519".path
            (builtins.toString ../static/id_ed25519.pub)
          ];
        };
      }
    ];
  };

  users.users = {
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
    owner = "1000";
  };
}
