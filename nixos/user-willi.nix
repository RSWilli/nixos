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

    users.willi = ../home-manager/home.nix;
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
        # gnome3.gpaste currently broken

        # language server for nix:
        nil
        nixpkgs-fmt
      ];
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
    };
  };
}
