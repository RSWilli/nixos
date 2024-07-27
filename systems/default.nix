# maybe auto import systems from subfolders. How to specify system arch?
# WIP:
# let
#   lib = self.lib;
#   base = toString ./.;
#   dirs = lib.mapAttrsToList (path: _: path) (lib.filterAttrs (_path: type: type == "directory") (builtins.readDir ./.));
#  in 
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
  latitude = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    inherit (self) lib;
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      ./latitude
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
