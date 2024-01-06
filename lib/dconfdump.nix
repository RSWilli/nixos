{pkgs, ...}:
pkgs.writeShellScriptBin "update-dconf" ''
  ${pkgs.dconf}/bin/dconf dump / | ${pkgs.dconf2nix}/bin/dconf2nix > dconf.nix
''
