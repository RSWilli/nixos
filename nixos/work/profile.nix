# packages and config needed for my work environment
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.work;
in {
  options.my.work = {
    enable = mkEnableOption "Work Apps";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dbgate
      chromium
      dig
      gitlabber

      obs-studio

      # make the tailscale command usable to users
      pkgs.tailscale
    ];

    # user need to run
    # sudo tailscale up --accept-routes
    # to start using tailscale

    services.tailscale.useRoutingFeatures = "client";

    # enable the tailscale service
    services.tailscale.enable = true;

    # trust the internal CA cert system wide
    security.pki.certificates = [
      (builtins.readFile ./internal-ca.pem)
      (builtins.readFile ./local-ca.pem)
    ];

    networking.extraHosts = ''
      127.0.0.1 local.streamonkey.net
    '';

    # configure https://github.com/ezbz/gitlabber
    environment.sessionVariables = {
      GITLABBER_FOLDER_NAMING = "path";
      GITLABBER_CLONE_METHOD = "ssh";
    };

    # configure npm to use a user-writable global package location, needed for npm link
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/npm.nix#L46
    environment.etc.npmrc.text = ''
      prefix = ''${HOME}/.npm
    '';
    environment.variables.NPM_CONFIG_GLOBALCONFIG = "/etc/npmrc";
  };
}
