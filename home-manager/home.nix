{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./dconf.nix
    ./vscode.nix
  ];

  home = {
    username = "willi";
    homeDirectory = "/home/willi";
  };

  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName  = "RSWilli";
    userEmail = "bartel.wilhelm@gmail.com";
    aliases = {
      pfush = "push --force-with-lease";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "terminalparty";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
