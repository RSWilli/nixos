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

      # fix wireplumber crashes gnome volume control:
      # https://gitlab.gnome.org/GNOME/libgnome-volume-control/-/issues/34
      # https://github.com/NixOS/nixpkgs/issues/475202
      (
        final: _prev: let
          stablepkgs = import inputs.nixpkgs-stable {
            system = final.system;
            config.allowUnfree = true;
          };
        in {
          wireplumber = stablepkgs.wireplumber;
        }
      )

      # override vscode version since 1.109.0 has security issues with copilot, see
      # https://github.com/microsoft/vscode/issues?q=is%3Aissue+is%3Aclosed+milestone%3A%22January+2026+Recovery+1%22+
      # https://github.com/microsoft/vscode/issues?q=is%3Aissue+is%3Aclosed+milestone%3A%22January+2026+Chat+Recovery+2%22+
      (
        final: prev: {
          vscode =
            prev.vscode.overrideAttrs
            (finalVscode: prevVscode: let
              plat = "linux-x64";
            in rec {
              version = "1.109.2";
              src = final.fetchurl {
                name = "VSCode_${version}_${plat}.tar.gz";
                url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
                hash = "sha256-ST5i8gvNtAaBbmcpcg9GJipr8e5d0A0qbdG1P9QViek=";
              };
            });
        }
      )
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
