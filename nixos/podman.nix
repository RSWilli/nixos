# rootless podman for local development, replaces docker
#
# containers run as the user (no root daemon, no docker group == root). Rootless networking
# uses pasta inside the user namespace, so no bridge on the host that could collide with
# networks like WIFIonICE (172.18.x.x).
#
# `docker` and `docker compose` keep working via dockerCompat. For tools that need the
# docker API socket (testcontainers, IDEs):
#   systemctl --user enable --now podman.socket
#   export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.podman;
in {
  options.my.podman = {
    enable = mkEnableOption "rootless podman";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;

        # `docker` alias for the podman CLI
        dockerCompat = true;

        # automatically run a prune schedule
        autoPrune.enable = true;
      };

      containers = {
        # resolve short image names against Docker Hub like docker does
        registries.settings.unqualified-search-registries = ["docker.io"];

        containersConf.settings.containers = {
          # bypass the netbird DNS override inside containers
          dns_servers = ["1.1.1.1" "8.8.8.8"];

          # don't copy the host's /etc/hosts into containers (docker doesn't either)
          base_hosts_file = "none";
        };
      };
    };

    environment.systemPackages = [
      pkgs.podman-compose # used by `podman compose` / `docker compose`; builds via buildah (supports additional_contexts)
    ];
  };
}
