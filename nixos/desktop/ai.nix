# enable a local llama-server instance for LLM-based tasks
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
    services.llama-cpp = {
      enable = true;
      port = 34000;
      openFirewall = false;

      modelsPreset = {
        "Gemma4-26B-A4B" = {
          hf-repo = "coder3101/gemma-4-26B-A4B-it-heretic";
          alias = " google/gemma-4-26B-A4B-it";
          # fit = "on";
          # seed = "3407";
          temp = "1.0";
          top-p = "0.95";
          # min-p = "0.01";
          top-k = "64";
          jinja = "on";
        };
        "Gemma4-E4B" = {
          hf-repo = "coder3101/gemma-4-E4B-it-heretic";
          alias = " google/gemma-4-E4B-it";
          # fit = "on";
          # seed = "3407";
          temp = "1.0";
          top-p = "0.95";
          # min-p = "0.01";
          top-k = "64";
          jinja = "on";
        };
      };
    };
  };
}
