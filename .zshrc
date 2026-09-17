# ============================================================
# HISTORY
# ============================================================
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS


# ============================================================
# SHELL OPTIONS
# ============================================================
setopt PROMPT_SUBST


# ============================================================
# ENVIRONMENT MANAGERS
# ============================================================
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# ============================================================
# COMPLETION
# ============================================================
autoload -Uz compinit
compinit


# ============================================================
# KEY BINDINGS
# ============================================================
source <(fzf --zsh)


# ============================================================
# FUNCTIONS
# ============================================================
user_host_prompt() {
    print -r -- "%F{blue}%n@$(hostname)%f"
}

path_prompt() {
    local path max_parts parts shown

    max_parts=2

    if [[ "$PWD" == "$HOME" ]]; then
        print -r -- "%F{cyan}~%f"
        return
    fi

    if [[ "$PWD" == "$HOME"/* ]]; then
        path="${PWD#$HOME/}"
        parts=("${(@s:/:)path}")

        if (( ${#parts[@]} <= max_parts )); then
            shown="~/${path}"
        else
            shown="~/.../${(j:/:)parts[-max_parts,-1]}"
        fi
    else
        shown="%~"
    fi

    print -r -- "%F{cyan}${shown}%f"
}

git_prompt() {
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch git_status changes sync ahead behind

    branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
    [[ -z "$branch" ]] && branch="$(git rev-parse --short HEAD 2>/dev/null)"

    git_status="$(git status --porcelain=v1 --branch 2>/dev/null)"

    # modified but not staged
    if print -r -- "$git_status" | command grep -qE '^.[MADRCU]'; then
        changes+="*"
    fi

    # staged
    if print -r -- "$git_status" | command grep -qE '^[MADRCU]'; then
        changes+="+"
    fi

    # untracked
    if print -r -- "$git_status" | command grep -qE '^\?\?'; then
        changes+="?"
    fi

    # ahead / behind upstream
    ahead="$(git rev-list --count @{u}..HEAD 2>/dev/null)"
    behind="$(git rev-list --count HEAD..@{u} 2>/dev/null)"

    [[ "$ahead" -gt 0 ]] 2>/dev/null && sync+=" ↑${ahead}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && sync+=" ↓${behind}"

    [[ -n "$changes" ]] && changes=" ${changes}"

    print -r -- "%F{yellow}git:${branch}${changes}${sync}%f"
}

conda_prompt() {
    [[ -n "$CONDA_DEFAULT_ENV" ]] || return

    print -r -- "%F{cyan}(${CONDA_DEFAULT_ENV})%f"
}

main_prompt() {
    local git_info conda_info sep

    git_info="$(git_prompt)"
    conda_info="$(conda_prompt)"
    sep="%F{blue}|%f"

    print
    if [[ -n "$git_info" ]]; then
        print -r -- "$(user_host_prompt) ${sep} $(path_prompt) ${sep} ${git_info}"
    else
        print -r -- "$(user_host_prompt) ${sep} $(path_prompt)"
    fi
    print -r -- "${conda_info}%F{cyan}%B>%b%f "
}


# ============================================================
# ALIASES
# ============================================================
alias ll='ls -AFGhl'

alias mv='mv -i'
alias mkdir='mkdir -p'

alias gs='git status'
alias gl='git log --oneline --graph --all --decorate'

alias brewu='brew update && brew upgrade && brew cleanup'


# ============================================================
# PROMPT
# ============================================================
PS1='$(main_prompt)'


# ============================================================
# INTERACTIVE INTEGRATIONS
# ============================================================
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

