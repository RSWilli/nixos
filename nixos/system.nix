{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  zramSwap = {
    enable = true;
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
  };
}
