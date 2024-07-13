{pkgs, ...}: {
  # TODO: auto import all files in this directory
  imports = [
    ./desktop/bootloader.nix
    ./desktop/comms
    ./desktop/comms/mumble.nix
    ./desktop/gnome.nix
    ./desktop/steam.nix
    ./docker.nix
    ./general.nix
    ./git
    ./i18n.nix
    ./nix.nix
    ./users.nix
    ./work
    ./zsh
  ];
}
