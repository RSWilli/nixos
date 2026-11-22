# Claude Code with its built-in sandbox (sandbox-runtime), configured the same
# on every machine via /etc/claude-code/managed-settings.json:
#  - Read/Write/Edit tools: no access outside the working directories
#  - Bash: runs in bubblewrap per command; home and secret sockets unreadable,
#    writes only to the project, .git/hooks, .git/config and .vscode of every
#    repo (also ones created mid-session) read-only, network by domain allowlist
#  - systemctl read commands work inside the sandbox via a read-only
#    system bus proxy
#  - auto mode: routine actions (incl. MCP, Claude in Chrome) need no
#    approval, risky ones do; commits work, fetch/push don't
#    (no SSH keys or tokens reachable)
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.claude;

  # Claude's own Go/npm/nix/... caches, separate from the user's. Private to
  # willi: others must never write here (cache poisoning), and have no
  # reason to read it.
  cache = "/var/cache/claude-sandbox";

  settings = {
    model = "opus[1m]";
    effortLevel = "medium";

    # show (summarized) thinking in the conversation and transcript (ctrl+o)
    alwaysThinkingEnabled = true;
    showThinkingSummaries = true;

    # hooks are shell commands; only allow ones defined here, never ones
    # written to user or project settings
    allowManagedHooksOnly = true;

    permissions = {
      # auto mode: a classifier approves routine actions (incl. MCP calls)
      # and only stops risky ones (exfiltration, destructive actions, ...).
      # Sandboxed commands and edits in the project never prompt.
      defaultMode = "auto";
      disableBypassPermissionsMode = "disable";

      # file tools (and sandboxed reads) stay inside the working directories
      blockReadsOutsideWorkingDirectories = true;
      blockWritesOutsideWorkingDirectories = true;
      blockReadsExemptPaths = [cache];

      # trusted MCP servers: all their tools, without asking the classifier
      allow = [
        "mcp__claude_ai_aireal_Live_Platform_MCP"
        "mcp__claude-in-chrome"
      ];
    };

    env = {
      XDG_CACHE_HOME = cache;
      GOPATH = "${cache}/go";
      npm_config_cache = "${cache}/npm";

      # Claude in Chrome: browser MCP tools via the Chrome/Chromium extension;
      # Claude installs the native messaging host manifest itself
      CLAUDE_CODE_ENABLE_CFC = "true";

      # read-only system bus for systemctl (see dbusProxy below)
      DBUS_SYSTEM_BUS_ADDRESS = "unix:path=${dbusProxySocket}";

      # request summarized thinking from the API so it can be shown, see
      # https://github.com/anthropics/claude-code/issues/54348#issuecomment-4337318753
      CLAUDE_CODE_EXTRA_BODY = builtins.toJSON {
        thinking = {
          type = "adaptive";
          display = "summarized";
        };
      };
    };

    sandbox = {
      enabled = true;
      failIfUnavailable = true;
      autoAllowBashIfSandboxed = true;
      allowUnsandboxedCommands = false;

      network = {
        # other domains ask once per session
        allowedDomains = [
          "proxy.golang.org"
          "sum.golang.org"
          "registry.npmjs.org"
          "cache.nixos.org"
          "channels.nixos.org"
          "github.com"
          "api.github.com"
          "codeload.github.com"
        ];
        # nix daemon socket; dangerous sockets are hidden below
        allowAllUnixSockets = true;
      };

      filesystem = {
        allowWrite = [cache];
        denyRead = [
          "/run/docker.sock" # docker group == root
          "/run/dbus" # the real system bus; systemctl uses dbusProxySocket
          "/run/user" # session bus, ssh/gpg agents, wayland
          "/run/netbird"
          "/run/agenix"
          "/run/agenix.d"
        ];
      };
    };
  };

  # Read-only system bus for the sandbox: xdg-dbus-proxy (the filter flatpak
  # uses) only passes systemd's read methods, so `systemctl status|show|cat|
  # list-*|is-*` work inside the sandbox, also in pipes and chains. Everything
  # else on the bus (StartUnit, NetworkManager, udisks, ...) is invisible. The
  # proxy runs as a throwaway user, so systemd/polkit see an identity without
  # any rights even if a call slipped through.
  dbusProxySocket = "/run/claude-dbus/system_bus_socket";

  systemdReadMethods = map (m: "org.freedesktop.systemd1.Manager.${m}@/org/freedesktop/systemd1") [
    "GetUnit"
    "GetUnitByPID"
    "LoadUnit"
    "GetUnitProcesses"
    "GetUnitFileState"
    "GetDefaultTarget"
    "ListUnits"
    "ListUnitsFiltered"
    "ListUnitsByPatterns"
    "ListUnitsByNames"
    "ListUnitFiles"
    "ListUnitFilesByPatterns"
    "ListJobs"
  ];

  dbusProxyRules =
    systemdReadMethods
    ++ concatMap (path: [
      "org.freedesktop.DBus.Properties.Get@${path}"
      "org.freedesktop.DBus.Properties.GetAll@${path}"
      "org.freedesktop.DBus.Introspectable.Introspect@${path}"
    ]) ["/org/freedesktop/systemd1" "/org/freedesktop/systemd1/*"];
in {
  options.my.claude.enable = mkEnableOption "claude code (sandboxed)";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      claude-code

      # sandbox runtime dependencies
      bubblewrap
      socat
      ripgrep

      # tools claude likes to use:
      python3
      jq
    ];

    environment.etc."claude-code/managed-settings.json".source =
      (pkgs.formats.json {}).generate "claude-managed-settings.json" settings;

    systemd.tmpfiles.rules = ["d ${cache} 0700 willi users -"];

    systemd.services.claude-dbus-proxy = {
      description = "Read-only system bus proxy for the Claude Code sandbox";
      wantedBy = ["multi-user.target"];
      after = ["dbus.service"];
      serviceConfig = {
        ExecStart = escapeShellArgs ([
            (getExe pkgs.xdg-dbus-proxy)
            "unix:path=/run/dbus/system_bus_socket"
            dbusProxySocket
            "--filter"
            "--see=org.freedesktop.systemd1"
          ]
          ++ map (r: "--call=org.freedesktop.systemd1=${r}") dbusProxyRules);
        Restart = "on-failure";
        DynamicUser = true;
        RuntimeDirectory = "claude-dbus";
        RuntimeDirectoryMode = "0755";
        UMask = "0000"; # socket usable by everyone: it only allows reads
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateNetwork = true; # unix sockets only
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
