{
  description = "golang development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self , nixpkgs ,... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };

      # golang package to use
      golang = pkgs.go_1_22;

    in pkgs.mkShell {
      packages = [
        golang
      ];

      GO111MODULE="on";

      # needed for running delve
      # https://github.com/go-delve/delve/issues/3085
      hardeningDisable = [ "all" ];

      # print the go version and gstreamer version on shell startup
      shellHook = ''
        ${golang}/bin/go version
      '';
    };
  };
}