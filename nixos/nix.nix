{
  inputs,
  outputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      outputs.overlays.additions
      outputs.overlays.working-rnnoise
    ];
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

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
    };
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
