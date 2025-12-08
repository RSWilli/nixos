{
  inputs,
  self,
  lib,
  pkgs,
  config,
  ...
}: {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      self.overlays.custompackages
      # # overlay master branch:
      # (final: _prev: {
      #   master = import inputs.nixpkgs-master {
      #     system = final.system;
      #     config.allowUnfree = true;
      #   };
      # })
    ];
  };
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    extraOptions = "experimental-features = nix-command flakes";

    gc = {
      automatic = true;
      options = let
        # at least 32GB of free space
        minFreeGB = 32;
        minfreeSpace = toString (minFreeGB * 1024 * 1024 * 1024);
      in "--max-freed ${minfreeSpace} --delete-older-than 14d";
      dates = "weekly";
    };

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: v: "${n}=${v}") flakeInputs;
  };

  environment.systemPackages = with pkgs; [
    # language server for nix, installed globally to have it available in all devshells
    nixd
    alejandra
  ];

  environment.sessionVariables = {
    # needed for nix helper aka nh
    NH_FLAKE = "/home/willi/nixos";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
