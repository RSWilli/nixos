{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.server.postgresql;
in {
  options.my.server.postgresql = {
    enable = mkEnableOption "postgresql";

    ensureDatabases = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of databases to ensure exist";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = cfg.ensureDatabases;
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust # local connections through Unix socket are trusted
      '';
    };
  };
}
