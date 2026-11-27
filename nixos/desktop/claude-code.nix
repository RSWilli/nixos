# Claude Code, whole process inside sandbox-runtime (srt):
#  - reads: project and ~/.claude only (no home, no secret sockets)
#  - writes: project, ~/.claude, /tmp, cache; settings files read-only
#  - network: domain allowlist, plus host loopback; ports listening on the
#    host are mirrored onto the sandbox's loopback (pasta)
#  - Bash/Read/Grep/Glob allowed outright, auto mode for the rest
#  - VS Code: claudeCode.claudeProcessWrapper = /run/current-system/sw/bin/claude
{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.claude;

  # Claude's own caches; private to willi (cache poisoning)
  cache = "/var/cache/claude-sandbox";

  settings = {
    model = "opus[1m]";
    effortLevel = "medium";

    # here, since Claude can't write its settings files
    theme = "light";
    tui = "fullscreen";
    autoMemoryEnabled = false;

    # show summarized thinking
    alwaysThinkingEnabled = true;
    showThinkingSummaries = true;

    # only hooks defined here
    allowManagedHooksOnly = true;

    permissions = {
      defaultMode = "auto";
      disableBypassPermissionsMode = "disable";

      # not blockReadsOutsideWorkingDirectories: it makes Bash ask for any
      # outside path; srt limits reads instead
      blockWritesOutsideWorkingDirectories = true;

      allow = [
        # bounded by srt
        "Bash"
        "Read"
        "Grep"
        "Glob"
        # trusted MCP servers
        "mcp__claude_ai_aireal_Live_Platform_MCP"
        "mcp__claude-in-chrome"
      ];
    };

    env = {
      XDG_CACHE_HOME = cache;
      GOPATH = "${cache}/go";
      npm_config_cache = "${cache}/npm";

      # Claude in Chrome
      CLAUDE_CODE_ENABLE_CFC = "true";
      # read-only system bus for systemctl
      DBUS_SYSTEM_BUS_ADDRESS = "unix:path=${dbusProxySocket}";

      # https://github.com/anthropics/claude-code/issues/54348#issuecomment-4337318753
      CLAUDE_CODE_EXTRA_BODY = builtins.toJSON {
        thinking = {
          type = "adaptive";
          display = "summarized";
        };
      };
    };

    # no built-in Bash sandbox: would nest bubblewrap inside srt
  };

  # relative paths: the directory claude is started in
  srtSettings = {
    network = {
      allowedDomains = [
        # Claude Code itself
        "anthropic.com"
        "*.anthropic.com"
        "claude.ai"
        "*.claude.ai"
        "claude.com"
        "*.claude.com"
        "*.claudeusercontent.com" # Claude in Chrome bridge

        # Go
        "*.golang.org"
        "storage.googleapis.com" # module zips from proxy.golang.org
        "go.dev"
        "*.go.dev"
        "gopkg.in"
        "*.googlesource.com"

        "github.com"
        "*.github.com"
        "*.githubusercontent.com"
        "*.npmjs.org"
        "pypi.org"
        "files.pythonhosted.org"
        "*.docker.io"
        "*.docker.com"
        "ghcr.io"
        "cache.nixos.org"
        "channels.nixos.org"

        "*.streamonkey.net"

        # local docker services; resolves to 127.0.0.1, which srt only
        # dials when allow-listed
        "local.streamonkey.net"
        "127.0.0.1"
      ];
      deniedDomains = []; # required by srt
      # nix daemon, dbus proxy; dangerous sockets hidden below
      allowAllUnixSockets = true;
    };

    filesystem = {
      denyRead = [
        "/home"
        "/root"
        "/mnt"
        "/media"
        "/run/media"
        "/srv"
        "/run/docker.sock" # docker group == root
        "/run/dbus" # the real system bus; systemctl uses dbusProxySocket
        "/run/user" # session bus, ssh/gpg agents, wayland
        "/run/netbird"
        "/run/agenix"
        "/run/agenix.d"
      ];
      allowRead = [
        "."
        "~/.claude"
        # private Go modules from GitLab; token readable by the sandbox
        "~/.netrc"
      ];
      allowWrite = [
        "."
        "~/.claude"
        "/tmp"
        cache
      ];
      # Must exist, or srt mounts an empty placeholder there. Project .claude
      # stays writable: srt mounts its own placeholders inside it.
      denyWrite = [
        "~/.claude/settings.json"
        "~/.claude/chrome" # Chrome runs the native host outside srt
      ];
    };
  };

  srtSettingsFile = (pkgs.formats.json {}).generate "claude-srt-settings.json" srtSettings;

  # Claude in Chrome: the browser manifests point at
  # ~/.claude/chrome/chrome-native-host, which Chrome starts unsandboxed.
  # Linked here so the sandbox can't change what runs.
  chromeNativeHost = pkgs.writeShellScript "chrome-native-host" ''
    export CLAUDE_CONFIG_DIR="$HOME/.claude"
    exec ${getExe pkgs.claude-code} --chrome-native-host
  '';

  # "." would expose all of it
  checkPwd = ''
    case "$PWD" in
      / | /home | "$HOME")
        echo "$0: not starting in $PWD, the sandbox would expose all of it" >&2
        exit 1
        ;;
    esac
  '';

  # Host ports on the sandbox's loopback: pasta binds every port bound on the
  # host in srt's network namespace too, forwarding to the host. Loopback only
  # (--splice-only), so srt's proxy stays the only way out. TCP only (srt never
  # carried UDP), no DNS (the host resolver would leak any name), no ephemeral
  # ports (pasta's auto default). Runs beside srt, whose pid it gets.
  hostLoopback = pkgs.writeScript "claude-host-loopback" ''
    #!${pkgs.python3}/bin/python3 -I
    import fcntl, os, subprocess, sys, time

    srt = int(sys.argv[1])


    def alive(pid):
        return os.path.exists(f"/proc/{pid}")


    # processes come and go while srt starts: a vanished one has no children
    # and no namespace
    def children(pid):
        try:
            tasks = os.listdir(f"/proc/{pid}/task")
            return [c for t in tasks for c in open(f"/proc/{pid}/task/{t}/children").read().split()]
        except OSError:
            return []


    def netns(pid):
        try:
            return os.readlink(f"/proc/{pid}/ns/net")
        except OSError:
            return None


    # first descendant of srt in another network namespace
    def find_sandbox():
        todo = children(srt)
        while todo:
            pid = todo.pop()
            if netns(pid) not in (own, None):
                return pid
            todo += children(pid)


    own = netns(srt)
    for _ in range(100):
        if not alive(srt):
            sys.exit()  # e.g. a quick --version
        pid = find_sandbox()
        if pid:
            break
        time.sleep(0.1)
    else:
        sys.exit("no sandbox process found")

    # The sandbox runs in a user namespace nested in the one owning its netns;
    # pasta joins the owner (NS_GET_USERNS). It closes inherited fds, so it
    # opens it through our /proc.
    net = os.open(f"/proc/{pid}/ns/net", os.O_RDONLY)
    user = fcntl.ioctl(net, 0xB701)
    pasta = subprocess.Popen([
        "${pkgs.passt}/bin/pasta", "-f", "--splice-only", "--no-netns-quit",
        "-t", "none", "-u", "none", "-T", "~53,auto", "-U", "none",
        "--userns", f"/proc/{os.getpid()}/fd/{user}",
        "--netns", f"/proc/{pid}/ns/net",
    ])
    while alive(srt) and pasta.poll() is None:
        time.sleep(1)
    pasta.terminate()
  '';

  # beside srt, which becomes $$ through exec
  startHostLoopback = "${hostLoopback} $$ </dev/null >/dev/null 2>>${cache}/host-loopback.log &";

  claude-sandboxed = pkgs.writeShellScriptBin "claude" ''
    ${checkPwd}
    # state in ~/.claude/.claude.json instead of ~/.claude.json
    export CLAUDE_CONFIG_DIR="$HOME/.claude"
    # VS Code's claudeProcessWrapper passes its bundled binary first: drop it
    if [[ ''${1-} == /* && -f ''${1-} && -x ''${1-} ]]; then shift; fi
    ${startHostLoopback}
    exec ${getExe pkgs.sandbox-runtime} --settings ${srtSettingsFile} -- ${getExe pkgs.claude-code} "$@"
  '';

  # interactive shell in the same sandbox, with the env Claude's Bash gets
  claude-shell = pkgs.writeShellScriptBin "claude-shell" ''
    ${checkPwd}
    ${toShellVars settings.env}
    export ${concatStringsSep " " (attrNames settings.env)}
    ${startHostLoopback}
    exec ${getExe pkgs.sandbox-runtime} --settings ${srtSettingsFile} -- ${getExe pkgs.bashInteractive} --norc
  '';

  # Read-only system bus: xdg-dbus-proxy passes only systemd's read methods
  # (systemctl status/show/cat/list-*/is-*), as a throwaway user without rights
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
      claude-sandboxed
      claude-shell

      # tools claude likes to use
      python3
      jq
    ];

    environment.etc."claude-code/managed-settings.json".source =
      (pkgs.formats.json {}).generate "claude-managed-settings.json" settings;

    systemd.tmpfiles.rules = [
      "d ${cache} 0700 willi users -"
      "d /home/willi/.claude/chrome 0755 willi users -"
      "L+ /home/willi/.claude/chrome/chrome-native-host - - - - ${chromeNativeHost}"
    ];

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
