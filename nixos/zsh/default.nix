{pkgs, ...}: {
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    nix-zsh-completions
  ];

  # enable direnv and nix-direnv
  programs.direnv.enable = true;

  # POSIX shell independend shell init, sourced before zsh shell init
  environment.shellInit = "";
  environment.interactiveShellInit = "";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true; # compatibility with bash completion
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableLsColors = true; # prettier `ls` output

    histSize = 10000;

    setOptions = [
      "APPEND_HISTORY" # Don't overwrite, append!
      "INC_APPEND_HISTORY" # Write after each command
      "SHARE_HISTORY" # Share history between multiple shells
      "HIST_IGNORE_DUPS" # If I type cd and then cd again, only save the last one
      "HIST_IGNORE_ALL_DUPS" # Even if there are commands inbetween commands that are the same, still only save the last one

      "HIST_REDUCE_BLANKS"
      "HIST_IGNORE_SPACE" # If a line starts with a space, don't save it.
      "HIST_NO_STORE"
      "HIST_VERIFY" # When using a hist thing, make a newline show the change before executing it.
      "EXTENDED_HISTORY" # Save the time and how long a command ran

      "HIST_SAVE_NO_DUPS"
      "HIST_EXPIRE_DUPS_FIRST"
      "HIST_FIND_NO_DUPS"

      "COMPLETE_ALIASES" # Prevents aliases on the command line from being internally substituted before completion is attempted.  The effect is to make the alias a distinct command for completion purposes.
    ];

    interactiveShellInit = builtins.readFile ./settings.zsh;

    promptInit = builtins.readFile ./prompt.zsh;
  };
}
