pkgs: {
  mkShellMinimal = pkgs.callPackage ./mkShellMinimal.nix {};
  gitlabber = pkgs.callPackage ./gitlabber.nix {};
}
