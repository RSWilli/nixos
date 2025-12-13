{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.ai;
in {
  options.my.ai = {
    enable = mkEnableOption "ai";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Ollama
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      loadModels = ["gemma3"];
    };
  };
}
