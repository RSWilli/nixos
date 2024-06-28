#!/usr/bin/env zsh

# Load promptinit
autoload -Uz promptinit && promptinit

function theme_precmd() {

    # this is a % char on the left side, green if the last command succeeded, red if failed
    PS1="%(?.%F{green}.%F{red})%#%f "

    # right prompt: current directory, git branch, hostname
    GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

    # add a space if there is a git branch
    if [ -n "$GIT_BRANCH" ]; then
        GIT_BRANCH=" $GIT_BRANCH"
    fi

    RPS1="%2~%F{yellow}${GIT_BRANCH} %B%F{blue}%m%b%f"
}

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd
