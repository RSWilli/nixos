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
      # MoE model (~4B active of 26B): keep all expert weights in system RAM and
      # only attention/dense layers + KV on the 16GB iGPU -- this is what makes
      # it fit. 999 > layer count, so effectively --cpu-moe (all experts on CPU).
      n-cpu-moe = "999";
      ctx-size = "16384"; # cap the model's 131072 default; saves a lot of KV memory
      parallel = "1"; # single user, and MTP speculative decoding wants n_parallel=1
      cache-reuse = "256"; # reuse cached KV across requests sharing a prefix
      sleep-idle-seconds = "600"; # release the GPU after 10 min idle
      spec-type = "draft-mtp";
      spec-draft-n-max = "3";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
    };
    "Gemma4-12B" = {
      hf = "unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL";
      alias = " google/gemma-4-12B-it";
      ngl = 999; # offload all layers
      # FA is effectively required here: this model has per-layer varying V head
      # dims, so with FA off llama.cpp pads the V cache to 2048/layer and the
      # 256k KV cache OOMs the 16GB iGPU (vk::Queue::submit: ErrorDeviceLost).
      fa = "on"; # flash attention
      # quantize the KV cache so the full 256k context fits in VRAM
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      ctx-size = "262144"; # full 256k context
      parallel = "1"; # single user, and MTP speculative decoding wants n_parallel=1
      cache-reuse = "256"; # reuse cached KV across requests sharing a prefix
      sleep-idle-seconds = "600"; # release the GPU after 10 min idle
      spec-type = "draft-mtp";
      spec-draft-n-max = "3";
      temp = "1.0";
      top-p = "0.95";
      top-k = "64";
    };
    "Gemma4-E4B" = {
      hf = "unsloth/gemma-4-E4B-it-qat-GGUF:UD-Q4_K_XL";
      alias = " google/gemma-4-E4B-it";
      ngl = 999; # offload all layers (small model, fits the GPU)
      fa = "off"; # flash attention
      ctx-size = "32768"; # small model -> room for a larger context
      parallel = "1"; # single user, and MTP speculative decoding wants n_parallel=1
      cache-reuse = "256"; # reuse cached KV across requests sharing a prefix
      sleep-idle-seconds = "600"; # release the GPU after 10 min idle
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
        metrics = true; # expose the Prometheus /metrics endpoint on the router
        # keep only one model resident; loading another evicts the LRU (the
        # other) one, so the two models don't fight over the 16GB iGPU.
        models-max = 1;
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
      pkgs.pi-coding-agent
    ];
  };
}
