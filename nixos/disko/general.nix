{lib, ...}:
with lib; {
  options.my.disko = {
    root-disk = mkOption {
      default = "/dev/nvme0n1";
      type = with types; string;
      description = ''
        The root disk that disko formats.
      '';
    };

    encrypted = mkOption {
      default = false;
      type = with types; bool;
      description = ''
        Whether to encrypt the root disk.
      '';
    };

    legacy-boot = mkOption {
      default = false;
      type = with types; bool;
      description = ''
        Format according to legacy boot mode.
      '';
    };
  };
}
