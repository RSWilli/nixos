{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.minecraft;
in {
  options.my.minecraft = {
    enable = mkEnableOption "minecraft";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # see https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/pr/prismlauncher/package.nix#L32 for options
      # https://wiki.nixos.org/wiki/Prism_Launcher#Advanced
      (prismlauncher.override {
        # # Add binary required by some mod
        # additionalPrograms = [ffmpeg];

        # # Change Java runtimes available to Prism Launcher
        # jdks = [
        #   graalvm-ce
        #   zulu8
        #   zulu17
        #   zulu
        # ];
      })
    ];
  };
}
