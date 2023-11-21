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

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    devshell.url = "github:numtide/devshell";
    # flake-utils.url = "github:numtide/flake-utils";

    flake-parts.url = "github:hercules-ci/flake-parts";
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
        nixosConfigurations = {
          think = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
              ./systems/think
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
      }: {
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
              help = "wrapper for nixos-rebuild switch";
              command = "sudo nixos-rebuild switch --flake .#$1";
            }
            {
              name = "update";
              help = "wrapper for nix flake update";
              command = "nix flake update";
            }
          ];
          packages = with pkgs; [];
        };
        devshells.install = {
          commands = [
            {
              name = "format";
              help = "format disk according to config";
              # sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko -- --flake github:rswilli/nixos#think --mode disko
              command = "sudo ${pkgs.lib.getExe' inputs'.disko.packages.default "disko"} --flake .#$1 --mode disko";
            }
            {
              name = "install";
              help = "install system";
              command = "sudo nixos-install --flake .#$1";
            }
          ];
        };
      };
    };
}
