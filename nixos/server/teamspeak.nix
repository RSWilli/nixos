{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.teamspeak;

  ts = config.containers.teamspeak.config.services.teamspeak3;
in {
  options.my.server.teamspeak = {
    enable = mkEnableOption "teamspeak";
  };

  config = mkIf cfg.enable {
    # teamspeak runs in a nspawn container, sharing the host network.
    # state lives in /var/lib/nixos-containers/teamspeak/var/lib/teamspeak3-server
    containers.teamspeak = {
      autoStart = true;

      # own uid/gid range, root in the container is not root on the host
      privateUsers = "pick";

      config = {
        # reuse the host pkgs, this also inherits allowUnfree
        nixpkgs.pkgs = pkgs;

        services.teamspeak3.enable = true;

        # the host network is shared, so the host firewall is the one that counts
        networking.firewall.enable = false;

        system.stateVersion = config.system.stateVersion;
      };
    };

    # the container start script copies the host /etc/resolv.conf once, so wait until
    # NetworkManager has a connection (and nameservers), otherwise DNS stays broken in the
    # container and ts3server shuts down after failing to reach the license server for 2h
    systemd.services."container@teamspeak" = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };

    networking.firewall = {
      # allowedTCPPorts = [ts.fileTransferPort]; # no file transfer allowed
      allowedUDPPortRanges = [
        {
          from = ts.defaultVoicePort;
          to = ts.defaultVoicePort + 10;
        }
      ];
    };
  };
}
