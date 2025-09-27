{
  description = "golang development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      pkgs.mkShell {
        packages = with pkgs; [
          go_latest
        ];

        GO111MODULE = "on";

        # needed for running delve with cgo
        # https://wiki.nixos.org/wiki/Go#Using_cgo_on_NixOS
        hardeningDisable = ["fortify"];

        shellHook = ''
          ${pkgs.go_latest}/bin/go version
        '';
      };
  };
}
