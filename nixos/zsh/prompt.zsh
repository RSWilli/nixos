#!/usr/bin/env zsh

# Load promptinit
autoload -Uz promptinit && promptinit

# Enable variable substitution in the prompt
setopt prompt_subst

function theme_precmd() {
    local branch_name
    branch_name="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

    # add a space and parenthesis if there is a git branch
    if [ -n "$branch_name" ]; then
        GIT_BRANCH=" ($branch_name)"
    else
        GIT_BRANCH=""
    fi
}

if [[ -n "$SSH_CONNECTION" ]]; then
    HOSTNAME_PROMPT="%B%F{blue}%m%b%f "
else
    HOSTNAME_PROMPT=""
fi

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd

# Define prompts once to avoid overwriting VS Code's shell integration injections
# Hostname (only in SSH), current directory, git branch, and status symbol (green if success, red if failed)
PS1='${HOSTNAME_PROMPT}%2~%F{yellow}${GIT_BRANCH}%f %(?.%F{green}.%F{red})%#%f '
