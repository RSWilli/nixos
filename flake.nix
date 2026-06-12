{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # wrapper-modules for wrapping packages to not require config files.
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # upstream llama.cpp flake: provides a current build (with MTP / newer model
    # architectures) instead of nixpkgs' lagging llama-cpp package.
    llama-cpp = {
      url = "github:ggml-org/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hardware quirks:
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    # graphical niri configuration module:
    nirimod = {
      url = "github:srinivasr/nirimod/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      # inputs.nixpkgs.follows = "nixpkgs"; # removed so we can use binary cache
    };

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

    getPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = [
          inputs.noctalia.overlays.default
          self.overlays.custompackages
        ];
      };

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    lib = nixpkgs.lib.extend (stdlib: _: {my = import ./lib {lib = stdlib;};});

    nixosConfigurations = import ./systems inputs;

    nixConfig = {
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    formatter = forAllSystems (system: (getPkgs system).alejandra);

    packages = forAllSystems (
      system:
        import ./packages (
          {
            pkgs = getPkgs system;
          }
          // inputs
        )
    );

    overlays = import ./overlays inputs;

    templates = {
      golang = {
        path = ./templates/golang;
        description = "Golang development environment";
      };
      "node+golang" = {
        path = ./templates/node+golang;
        description = "Golang Nodejs development environment";
      };
    };

    devShells = forAllSystems (system: let
      pkgs = getPkgs system;
    in {
      default = pkgs.custompackages.mkShellMinimal {
        packages = [
          pkgs.nh
          pkgs.dconf
          pkgs.dconf2nix
          (
            pkgs.writeShellScriptBin "agenix" ''
              EDITOR="code --wait" ${pkgs.lib.getExe' agenix.packages.${system}.default "agenix"} "$@"
            ''
          )
          (
            pkgs.writeShellScriptBin "boot" ''
              ${pkgs.nh}/bin/nh os boot -- --show-trace
            ''
          )
          (
            pkgs.writeShellScriptBin "apply" ''
              ${pkgs.nh}/bin/nh os switch -- --show-trace
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
}
