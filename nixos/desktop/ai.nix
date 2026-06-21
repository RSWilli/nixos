# enable a local llama-server instance for LLM-based tasks
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.ai;

  # settings shared by every preset
  common = {
    parallel = "1"; # single user (also: MTP speculative decoding wants n_parallel=1)
    cache-reuse = "256"; # reuse cached KV across requests sharing a prefix
    sleep-idle-seconds = "600"; # release the GPU after 10 min idle

    fa = "on"; # flash attention
    cache-type-k = "q8_0";
    cache-type-v = "q8_0";
  };

  # MTP speculative decoding, shared by the Gemma presets
  specMTP = {
    spec-type = "draft-mtp";
    spec-draft-n-max = "2";
    top-k = "64";
  };

  gemma4Common = {
    # Gemma4 recommended sampling
    temp = "1.0";
    top-p = "0.95";
    top-k = "64";
  };

  qwen3Common = {
    # Qwen3 recommended sampling for "WebDev" (code generation benefits from more focused decoding)
    temp = "0.6";
    top-p = "0.95";
    top-k = "20";
    min-p = "0.0";
    presence-penalty = "0.0";
    repeat-penalty = "1.0";
  };

  modelsPreset = pkgs.writeText "llama-models.ini" (lib.generators.toINI {} {
    "Qwen3.6-35B-A3B" =
      common
      // qwen3Common
      // {
        hf = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL";
        n-cpu-moe = "999"; # MoEs on the CPU
        fa = "on"; # flash attention
        ctx-size = "16384"; # cap the model's 262144 default; saves a lot of KV memory
      };
    "Qwen3.6-35B-A3B-IQ3_S" =
      common
      // qwen3Common
      // {
        hf = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-IQ3_S";
        ctx-size = "16384"; # cap the model's 262144 default; saves a lot of KV memory
      };
    "Gemma4-26B-A4B" =
      common
      // gemma4Common
      // specMTP
      // {
        hf = "unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL";
        n-cpu-moe = "999"; # MoEs on the CPU
        ctx-size = "16384"; # cap the model's 131072 default; saves a lot of KV memory
      };
    "Gemma4-12B" =
      common
      // gemma4Common
      // specMTP
      // {
        hf = "unsloth/gemma-4-12B-it-qat-GGUF:UD-Q4_K_XL";
        ngl = 999; # all layers on GPU
        ctx-size = "262144"; # full 256k context
      };
    "Gemma4-E4B" =
      common
      // gemma4Common
      // specMTP
      // {
        hf = "unsloth/gemma-4-E4B-it-qat-GGUF:UD-Q4_K_XL";
        ngl = 999; # all layers on GPU
        ctx-size = "32768"; # small model -> room for a larger context
      };
  });
in {
  options.my.ai = {
    enable = mkEnableOption "ai";
  };

  config = mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp;
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

    environment.systemPackages = with pkgs; [
      pi-coding-agent
    ];
  };
}
