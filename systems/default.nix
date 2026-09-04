{
  self,
  nixpkgs,
  agenix,
  ...
} @ inputs: let
  mkGenericSystem = system: path:
    nixpkgs.lib.nixosSystem {
      inherit system;
      inherit (self) lib;
      specialArgs = {
        inherit inputs self;
      };
      modules = [
        path
        "${path}/hardware-configuration.nix"
        "${path}/disko.nix"
        agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        ../nixos
      ];
    };
  x64System = mkGenericSystem "x86_64-linux";
in {
  dell = x64System ./dell;
  homelab = x64System ./homelab;
  main = x64System ./main;
  think = x64System ./think;
}
