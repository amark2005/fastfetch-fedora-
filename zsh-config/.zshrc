# Created by newuser for 5.9
# Created by newuser for 5.9
eval "$(starship init zsh)"
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# export
#export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
#[[ -f ~/.zprofile ]] && source ~/.zprofile


# plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting

autoload -U compinit && compinit
autoload -U colors && colors
autoload -z edit-command-line

# cmp
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# opts
setopt interactivecomments
setopt append_history inc_append_history share_history
setopt autocd
setopt auto_param_slash
setopt no_case_glob no_case_match

# Add nvim as editor
export EDITOR="nano"

# mkdir + cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# history opts
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zhistory
HISTDUP=erase
setopt hist_save_no_dups
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# alias
alias ls='eza --icons'
# alias glog ='git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all'
#alias lh='eza -a'
alias cat='bat'
alias grep='rg'
alias dnf='dnf5'
# fzf
source <(fzf --zsh)

# Locale fix for UTF-8
export LANG="en_IN.UTF-8"
export LANGUAGE="en_IN.UTF-8:en_US.UTF-8"
export LC_ALL="en_IN.UTF-8"

fastfetch
