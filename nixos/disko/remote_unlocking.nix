{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.disko;
  initrd_ssh = config.boot.initrd.network.ssh;

  # publicKey = lib.my.initrd-ssh-host-pubkey;

  # provide an easy script that connects to the given host and expects the public key that
  # differs from the normal host key
  remote-unlock = pkgs.writeScriptBin "remote-unlock" ''
    host=$${1:?Usage: $0 <host>}
    port=${initrd_ssh.port}

    ssh -p "$port" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$host"
  '';
in {
  options.my.disko = {
    remote-unlocking = mkEnableOption "remote unlocking";
  };

  config = mkIf cfg.remote-unlocking {
    age.secrets = {
      initrd-ssh-host-key.file = ../../secrets/initrd-ssh-host-key.age;
    };

    environment.systemPackages = [
      remote-unlock
    ];

    boot.kernelParams = ["ip=dhcp"];
    boot.initrd = {
      availableKernelModules = ["r8169"];
      systemd.users.root.shell = "/bin/cryptsetup-askpass";
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 22;
          authorizedKeys = [lib.my.publicKey];
          hostKeys = [
            config.age.secrets."initrd-ssh-host-key".path
          ];
        };
      };
    };
  };
}
