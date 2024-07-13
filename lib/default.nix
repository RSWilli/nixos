{lib, ...}: rec {
  listModulesRecursivly = dir: let
    entries = builtins.readDir dir;
    modules = lib.mapAttrsToList (path: _: "${dir}/${path}") (lib.filterAttrs (path: type: type == "regular" && lib.hasSuffix ".nix" path) entries);
    subdirs = lib.mapAttrsToList (path: _: "${dir}/${path}") (lib.filterAttrs (path: type: type == "directory") entries);
  in
    modules ++ lib.concatMap listModulesRecursivly subdirs;
}
