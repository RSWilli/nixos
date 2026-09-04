# auto unlock LUKS device with TPM2
# https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.luksAutoUnlock;
in {
  options.my.luksAutoUnlock = {
    enable = mkEnableOption "luksAutoUnlock";
  };

  # needs a command run by the user:
  # systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<my encrypted device>
  config = mkIf cfg.enable {
    boot.initrd.systemd.enable = true;

    environment.systemPackages = [pkgs.tpm2-tss];
  };
}
