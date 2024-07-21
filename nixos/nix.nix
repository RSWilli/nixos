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
      self.overlays.working-rnnoise
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
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  environment.systemPackages = with pkgs; [
    # language server for nix:
    nil
    nixpkgs-fmt
  ];

  environment.sessionVariables = {
    # needed for nix helper aka nh
    FLAKE = "/home/willi/nixos";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
