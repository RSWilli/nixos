{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.disk;
in {
  options.my.disk = {
    remote-unlocking = mkEnableOption "remote unlocking";
  };

  config = mkIf cfg.remote-unlocking {
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
          # This key is not managed by this flake, make sure it exists:
          hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
        };
      };
    };
  };
}
