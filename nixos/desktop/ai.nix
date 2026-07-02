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
      "Ornith-1.0-9B" =
      common
      // qwen3Common # Qwen 3.5-based; recommended sampling matches (temp 0.6, top-p 0.95, top-k 20)
      // {
        # no Gemma MTP draft, so specMTP is omitted.
        # see https://huggingface.co/deepreinforce-ai/Ornith-1.0-9B-GGUF
        hf = "deepreinforce-ai/Ornith-1.0-9B-GGUF:Q8_0";
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

    backend = mkOption {
      type = types.enum ["rocm" "vulkan"];
      default = "rocm";
      description = ''
        GPU backend for llama-cpp.
        "rocm"   - HIP backend, for discrete AMD GPUs (RX 7800 XT / gfx1101).
        "vulkan" - RADV backend; faster on RDNA 3.5 iGPUs (gfx1152) and can use
                   GTT / shared system RAM instead of the small VRAM carveout.
      '';
    };

    rocmGpuTargets = mkOption {
      type = types.str;
      default = "gfx1101";
      description = ''Semicolon-separated HIP gfx targets; only used when backend = "rocm".'';
    };
  };

  config = mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      # GPU backend selected per-host via my.ai.backend:
      #   main -> rocm   (RX 7800 XT, gfx1101)
      #   dell -> vulkan (Radeon 860M iGPU, gfx1152: RADV is faster + uses GTT)
      # see https://github.com/ggml-org/llama.cpp/blob/master/.devops/nix/package.nix
      package = pkgs.llama-cpp.override ({
          useRocm = cfg.backend == "rocm";
          useVulkan = cfg.backend == "vulkan";
        }
        // lib.optionalAttrs (cfg.backend == "rocm") {
          # build HIP kernels only for this host's GPU arch
          rocmGpuTargets = cfg.rocmGpuTargets;
        });
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

    # upstream's module hardens the unit for a CPU-only default; relax only the
    # knobs the GPU backends actually need. MemoryDenyWriteExecute must go for
    # the ROCm/Vulkan runtime kernel & shader JIT; ProcSubset/ProtectProc let
    # ROCm read /proc/meminfo and peer-process info during device init.
    systemd.services.llama-cpp = {
      serviceConfig = {
        ProcSubset = lib.mkForce "all";
        ProtectProc = lib.mkForce "default";
        MemoryDenyWriteExecute = lib.mkForce false;
      };

      # merged with upstream's serviceConfig.Environment (LLAMA_CACHE) instead
      # of force-replacing it. HOME/XDG_CACHE_HOME give the DynamicUser a
      # writable location for the Mesa/ROCm shader & kernel caches.
      environment =
        {
          HOME = "/var/cache/llama-cpp";
          XDG_CACHE_HOME = "/var/cache/llama-cpp";
        }
        # system services don't inherit the session's Vulkan ICD var, so point
        # RADV discovery at the AMD driver explicitly.
        // lib.optionalAttrs (cfg.backend == "vulkan") {
          VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
        };
    };

    environment.sessionVariables = {
      # for pi-llama-cpp, see https://pi.dev/packages/pi-llama-cpp
      LLAMA_SERVER_URL = "http://localhost:${toString config.services.llama-cpp.settings.port}";
    };

    environment.systemPackages = with pkgs; [
      pi-coding-agent
      nodejs # required for installing plugins for pi-coding-agent
    ];
  };
}
