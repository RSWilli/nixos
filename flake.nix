{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # rnnoise 0.2 is broken, so we use the old version:
    nixpkgs-rnnoise.url = "github:nixos/nixpkgs/1d91b59670d5a9785c87a4e63a19695727166598";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hardware quirks:
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # nix-build requires a default.nix file
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    lib = nixpkgs.lib.extend (self: _: {my = import ./lib {lib = self;};});

    nixosConfigurations = import ./systems inputs;

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    packages = forAllSystems (system: import ./packages nixpkgs.legacyPackages.${system});

    overlays = import ./overlays {inherit inputs;};

    templates = {
      golang = {
        path = ./templates/golang;
        description = "Golang development environment";
      };
    };

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.custompackages
        ];
      };
    in {
      default = pkgs.mkShellMinimal {
        packages = [
          pkgs.nh
          (
            pkgs.writeShellScriptBin "agenix" ''
              EDITOR="code --wait" ${pkgs.lib.getExe' agenix.packages.${system}.default "agenix"} "$@"
            ''
          )
          (
            pkgs.writeShellScriptBin "boot" ''
              ${pkgs.nh}/bin/nh os boot
            ''
          )
          (
            pkgs.writeShellScriptBin "apply" ''
              ${pkgs.nh}/bin/nh os switch
            ''
          )
          (
            pkgs.writeShellScriptBin "update" ''
              nix flake update
            ''
          )
        ];
      };
    });
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
