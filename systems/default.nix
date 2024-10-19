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
  main = x64System ./main;
  latitude = x64System ./latitude;
  think = x64System ./think;
  cloud = x64System ./cloud;
}
