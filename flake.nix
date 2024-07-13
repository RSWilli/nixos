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
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    devshell,
    flake-parts,
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
      pkgs = nixpkgs.legacyPackages.${system};
      mypkgs = self.packages.${system}; # TODO: how to overlay?
    in {
      default = mypkgs.mkShellMinimal {
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
          (
            pkgs.writeShellScriptBin "build_iso" ''
              nix build .#nixosConfigurations.iso.config.system.build.isoImage --show-trace
            ''
          )
        ];
      };
    });
  };
}
