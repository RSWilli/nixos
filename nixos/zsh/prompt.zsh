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

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd

# Define prompts once to avoid overwriting VS Code's shell integration injections
# this is a % char on the left side, green if the last command succeeded, red if failed
PS1='%(?.%F{green}.%F{red})%#%f '

# right prompt: current directory, git branch, hostname
# Uses ${GIT_BRANCH} which is updated by the precmd hook
RPS1='%2~%F{yellow}${GIT_BRANCH} %B%F{blue}%m%b%f'

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Disable RPS1 in VS Code to fix Copilot command detection
    unset RPS1
fi
