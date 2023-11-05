# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];

  programs.zsh.enable = true;
  environment.shells = with pkgs; [
    zsh
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.willi = ../home-manager/home.nix;
  };

  users.users = {
    willi = {
      isNormalUser = true;
      description = "Wilhelm Bartel";
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;
      packages = with pkgs; [
        firefox
        telegram-desktop
        gnome.adwaita-icon-theme
        gnome.gnome-tweaks
        arc-theme
        # gnome3.gpaste
      ];
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
    };
  };
}
