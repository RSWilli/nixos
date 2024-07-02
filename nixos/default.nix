{pkgs, ...}: {
  imports = [
    ./git
    ./i18n.nix
    ./users.nix
    ./nix.nix
    ./zsh
  ];

  environment.systemPackages = with pkgs; [
    htop
  ];
}
