{pkgs, ...} @ inputs: {
  mkShellMinimal = pkgs.callPackage ./mkShellMinimal.nix {};
  gitlabber = pkgs.callPackage ./gitlabber.nix {};

  niri = pkgs.callPackage ./niri.nix {
    niriWrapper = inputs.wrapper-modules.wrappers.niri.wrap;
  };
  noctalia-shell = pkgs.callPackage ./noctalia-shell.nix {
    noctaliaShellWrapper = inputs.wrapper-modules.wrappers.noctalia-shell.wrap;
  };
}
