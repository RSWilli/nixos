{pkgs, ...}: {
  users.defaultUserShell = pkgs.zsh;

  environment.shells = [
    pkgs.zsh
  ];

  environment.systemPackages = with pkgs; [
    nix-zsh-completions
  ];

  # enable direnv and nix-direnv
  programs.direnv.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true; # compatibility with bash completion
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 10000;

    ohMyZsh = {
      enable = true;
      theme = "terminalparty";
    };

    # maybe someday I will do the theming manually:
    # this is missing some shortcuts, the autocompletion selection and the right prompt is not correct.

    # promptInit = ''
    #   autoload -Uz vcs_info
    #   precmd_vcs_info() { vcs_info }
    #   precmd_functions+=( precmd_vcs_info )
    #   setopt prompt_subst

    #   # enable vcs_info only for git
    #   zstyle ':vcs_info:*' enable git

    #   # print style of the version info=branch
    #   # zstyle ':vcs_info:git:*' formats '%b'

    #   # this is a % char on the left side, green if the last command succeeded, red if failed
    #   PROMPT='%(?.%F{green}.%F{red}) %% %f%b'

    #   # right prompt: current directory, git branch, hostname
    #   RPROMPT='%2~%F{yellow}$${vcs_info_msg_0_} %B%F{blue}%m%b%f' 
    # '';
  };
}
