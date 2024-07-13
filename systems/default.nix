{
  self,
  nixpkgs,
  agenix,
  ...
} @ inputs: {
  main = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit (self) lib;
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      ./main
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
  think = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit (self) lib;
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      ./think
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
  iso = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit (self) lib;
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      ./iso
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
}
