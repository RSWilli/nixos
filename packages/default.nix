pkgs: {
  mkShellMinimal = pkgs.callPackage ./mkShellMinimal.nix {};
  stabilityMatrix = pkgs.callPackage ./stabilityMatrix {};
}
