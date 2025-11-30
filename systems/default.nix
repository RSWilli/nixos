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
        agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        ../secrets/config.nix
        ../nixos
      ];
    };
  x64System = mkGenericSystem "x86_64-linux";
in {
  cloud = x64System ./cloud;
  dell = x64System ./dell;
  main = x64System ./main;
  think = x64System ./think;
}
