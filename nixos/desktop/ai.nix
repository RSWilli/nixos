# enable a local llama-server instance for LLM-based tasks
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.ai;

  llama-cpp = pkgs.llama-cpp.override {
    useVulkan = true;
    useRocm = false;
  };

  # The llama-cpp module no longer accepts a Nix attrset for model presets
  # (services.llama-cpp.modelsPreset was removed); it now wants a path to an
  # INI file passed via settings.models-preset. Generate that file from the
  # same data the old attrset held.
  modelsPreset = pkgs.writeText "llama-models.ini" (lib.generators.toINI {} {
    "Gemma4-26B-A4B" = {
      hf = "unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL";
      alias = " google/gemma-4-26B-A4B-it";
      # device = "Vulkan0";
      spec-type = "draft-mtp";
      spec-draft-n-max = "3";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
    };
    "Gemma4-E4B" = {
      hf = "unsloth/gemma-4-E4B-it-qat-GGUF:UD-Q4_K_XL";
      alias = " google/gemma-4-E4B-it";
      # device = "Vulkan0";
      spec-type = "draft-mtp";
      spec-draft-n-max = "3";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
    };
  });
in {
  options.my.ai = {
    enable = mkEnableOption "ai";
  };

  config = mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      package = llama-cpp;
      openFirewall = false;

      # llama-server CLI args (foo = bar => --foo bar).
      settings = {
        port = 34000;
        models-preset = modelsPreset;
      };
    };

    # The upstream NixOS llama-cpp module ships an aggressive systemd sandbox
    # that breaks GPU compute on this AMD APU (Radeon 860M, integrated -> VRAM
    # is system RAM). Relax the parts the Vulkan/ROCm backend needs:
    #  - ProcSubset/ProtectProc hide /proc/meminfo -> UMA memory detection fails
    #    (the spammed "failed to open /proc/meminfo" errors + stalled -fit step)
    #  - MemoryDenyWriteExecute blocks the W+X pages the RADV/ROCm JIT shader
    #    compiler needs -> warmup hangs forever
    #  - HOME=/ is read-only -> Vulkan shader cache disabled (perf)
    systemd.services.llama-cpp.serviceConfig = {
      ProcSubset = lib.mkForce "all";
      ProtectProc = lib.mkForce "default";
      MemoryDenyWriteExecute = lib.mkForce false;
      Environment = lib.mkForce [
        "LLAMA_CACHE=/var/cache/llama-cpp"
        "HOME=/var/cache/llama-cpp"
        "XDG_CACHE_HOME=/var/cache/llama-cpp"
      ];
    };

    environment.systemPackages = [
      # also make the binary available for testing
      llama-cpp
    ];
  };
}
