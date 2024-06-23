{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  home = {
    username = "willi";
    homeDirectory = "/home/willi";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "RSWilli";
    userEmail = "bartel.wilhelm@gmail.com";
    aliases = {
      pfush = "push --force-with-lease";
    };
    extraConfig = {
      pull.rebase = "true";
    };
  };

  # TODO: move vscode config into nix system config
  programs.vscode = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
