pkgs: {
  mkShellMinimal = pkgs.callPackage ./mkShellMinimal.nix {};
  pulseaudioCombinedSink = pkgs.callPackage ./pulseaudioCombinedSink.nix {};
}
