{
  self,
  nixpkgs,
  agenix,
  ...
} @ inputs: {
  main = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit (self) outputs;
    };
    modules = [
      ./main
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
  think = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit (self) outputs;
    };
    modules = [
      ./think
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
  iso = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit (self) outputs;
    };
    modules = [
      ./iso
      agenix.nixosModules.default
      ../secrets/config.nix
    ];
  };
}
