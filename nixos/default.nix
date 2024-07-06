{pkgs, ...}: {
  # TODO: auto import all files in this directory
  imports = [
    ./git
    ./i18n.nix
    ./users.nix
    ./nix.nix
    ./work
    ./general.nix
    ./comms
    ./comms/mumble.nix
    ./zsh
  ];
}
