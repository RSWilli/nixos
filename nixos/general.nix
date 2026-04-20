{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
    lm_sensors # for the `sensors` command
    numbat # terminal unit converter and calculator

    # utility tools, replacements for some coreutils
    ripgrep # search files in folder, see https://github.com/burntsushi/ripgrep
    fd # find files with `fd <pattern>`, see https://github.com/sharkdp/fd
    fzf # TUI for searching current directory, see https://github.com/junegunn/fzf
  ];

  programs.fzf.fuzzyCompletion = true;

  # enforce that all users are configured via this flake
  users.mutableUsers = false;

  zramSwap = {
    enable = true;
  };
}
