{modulesPath, ...}: {
  # do not include secrets in the iso
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../nixos/git
    ../../nixos/i18n.nix
    ../../nixos/nix.nix
    ../../nixos/zsh
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = [];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
