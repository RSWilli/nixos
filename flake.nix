{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    agenix.url = "github:ryantm/agenix";

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

    # remote nixos installation:
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";

    devshell.url = "github:numtide/devshell";
    # flake-utils.url = "github:numtide/flake-utils";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # compatibility with nix-shell (e.g. while installing a new system from live usb):
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    devshell,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        devshell.flakeModule
      ];

      flake = {
        templates = {
          golang = {
            path = ./templates/golang;
            description = "Golang development environment";
          };
        };
        nixosConfigurations = {
          main = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
              ./systems/main
              agenix.nixosModules.default
              ./secrets/config.nix
            ];
          };
          think = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
              ./systems/think
              agenix.nixosModules.default
              ./secrets/config.nix
            ];
          };
          iso = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
              ./systems/iso
              agenix.nixosModules.default
              ./secrets/config.nix
            ];
          };
        };
      };
      systems = [
        "x86_64-linux"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      } @ perSystemInputs: {
        formatter = pkgs.alejandra;
        devshells.default = {
          commands = [
            {
              name = "agenix";
              help = "wrapper around agenix using vscode as editor";
              command = ''
                EDITOR="code --wait" ${pkgs.lib.getExe' inputs'.agenix.packages.default "agenix"} "$@"
              '';
            }
            {
              name = "pacsearch";
              help = "search nixpkgs for packages";
              command = ''
                nix-env -q | grep
              '';
            }
            {
              name = "apply";
              help = "wrapper for nixos-rebuild switch for the current system";
              command = "sudo nixos-rebuild switch --flake .#$(hostname) --show-trace";
            }
            {
              name = "update";
              help = "wrapper for nix flake update";
              command = "nix flake update";
            }
            {
              name = "build_iso";
              help = "build the custom ISO image";
              command = "nix build .#nixosConfigurations.iso.config.system.build.isoImage --show-trace";
            }
            {
              name = "update-dconf";
              help = "update dconf.nix settings";
              package = (import ./lib/dconfdump.nix) perSystemInputs;
            }
          ];
        };
      };
    };
}
