################################### ENVIRONMENT ####################################

# Locale
export LANG=en_US.UTF-8

# Editors
export EDITOR="nvim"
export VISUAL="nvim"

# Homebrew
export HOMEBREW_NO_AUTO_UPDATE="1"

# Android Studio
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

################################### PATH EXPORTS ###################################

export PATH=/usr/local/bin:$PATH
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH="$PATH:/Users/berenar/development/flutter/bin"
export PATH=/Users/berenar/.opencode/bin:$PATH

################################### CUSTOM VARIABLES ###############################

export Z="$HOME/.zshrc"
export N="$HOME/.config/nvim"
export A="$HOME/.aws/config"

################################### ZSH OPTIONS ####################################

setopt prompt_subst
unsetopt share_history

################################### PROMPT #########################################

PROMPT='%F{140}$(print -P %~)%F{blue} $(git_branch_name)%F{yellow} $(git_tag)%F{reset}'

################################### COMPLETION #####################################

autoload -Uz compinit
compinit

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

################################### KEY BINDINGS ###################################

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

################################### ALIASES ########################################

# General
alias 'cd..'='cd_up'
alias a="opencode --continue"
alias t="tmux a"

# Vim
alias v="nvim"
alias vi="nvim"

# Lazygit
alias l="lazygit"

# Git
alias g="git"
alias gcl=gclone_cd
alias gr="g restore"
alias grs="g restore --staged"
alias gs=" g status"
alias gb="g branch"
alias gst="g stash"
alias gstm="g stash -m"
alias gd="g diff && g diff --cached"
alias gch="g checkout"
alias gcha="g checkout-branch -a"
alias gp="g pull --rebase"
alias gf="g fetch"
alias gfp="gf --prune"
alias gl="g log"
alias glt="gl --all --oneline --decorate-refs=refs/heads --graph"
alias glto="git log --graph --oneline --abbrev-commit --decorate  --first-parent"
alias gchp="g cherry-pick"
alias ga="g add"
alias gc="g commit"
alias gcm="gc -m"
alias gca="gc --amend"
alias gcan="gca --no-edit"
alias gm="g merge"
alias gu="g reset --soft HEAD~1"
alias gph="g push"
alias gpr=git_open_pr

# Development tools
alias y="yarn"
alias b="bun"
alias p="pnpm"
alias f="flutter"

# SSH
alias raspberri="ssh -i /Users/berenar/.ssh/raspberri.pem berenar@raspberrypizero2w.local"

################################### FUNCTIONS ######################################

mkcdir() {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

precmd() {
  cdate=$(date +'%d-%m-%Y')
}

gclone_cd() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

git_branch_name() {
  branch=$(git symbolic-ref HEAD --quiet 2>/dev/null | awk 'BEGIN{FS="heads/"} {print $NF}')
  if [[ $branch == "" ]]; then
    head=$(git rev-parse --short HEAD 2>/dev/null)
    if [[ $head == "" ]]; then
    else
      echo '(detached '$head')'
    fi
  else
    echo '('$branch')'
  fi
}

git_tag() {
  tag=$(git tag --points-at 2>/dev/null)
  if [[ $tag == "" ]]; then
    :
  else
    echo '#('$tag')'
  fi
}

function cd_up() {
  cd $(printf "%0.s../" $(seq 1 $1))
}

function vpn-connect {
  /usr/bin/env osascript <<-EOF
tell application "System Events"
        tell current location of network preferences
                set VPN to service "MVST VPN"
                if exists VPN then connect VPN
                repeat while (current configuration of VPN is not connected)
                    delay 1
                end repeat
        end tell
end tell
EOF
}

function vpn-disconnect {
  /usr/bin/env osascript <<-EOF
tell application "System Events"
        tell current location of network preferences
                set VPN to service "MVST VPN"
                if exists VPN then disconnect VPN
        end tell
end tell
return
EOF
}

################################### EXTERNAL SOURCES ###############################

# Load secrets
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

################################### NVM ############################################

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

################################### ZOXIDE #########################################

eval "$(zoxide init zsh)"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/berenar/.bun/_bun" ] && source "/Users/berenar/.bun/_bun"

# Added by Antigravity
export PATH="/Users/berenar/.antigravity/antigravity/bin:$PATH"
