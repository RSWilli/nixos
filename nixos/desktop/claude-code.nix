{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.claude;
in {
  options.my.claude = {
    enable = mkEnableOption "claude code";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      claude-code

      # for sandboxing:
      bubblewrap
      socat

      # tools claude likes to use:
      python3
    ];
  };
}
