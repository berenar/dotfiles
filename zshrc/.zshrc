export LANG=en_US.UTF-8

export VISUAL="code --wait"
export EDITOR="nvim"

# Disable Homebrew auto update because I use https://github.com/DomT4/homebrew-autoupdate
export HOMEBREW_NO_AUTO_UPDATE="1"

# Load secrets
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets

# Android Studio
export ANDROID_HOME=~/Library/Android/sdk

export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# React Native for Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# Load Git completion
# zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
# fpath=(~/.zsh $fpath)
zstyle ':completion:*' menu select
# zmodload zsh/complist
# autoload -Uz compinit && compinit
# _comp_options+=(globdots)		# Include hidden files.

# Add kubectl autocompletion
# source <(kubectl completion zsh)

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

#################################### VARIABLES ####################################
# Home path
# export H="$HOME"
# just do "cd"

# This file's absolute path
export Z="$HOME/.zshrc"

export N="$HOME/.config/nvim"


# AWS config file path
export A="$HOME/.aws/config"

# Enable substitution in the prompt.
setopt prompt_subst

# Custom prompt
PROMPT='%F{140}$(print -P %~)%F{blue} $(git_branch_name)%F{yellow} $(git_tag)%F{reset}'

#################################### ALIASES ###################################

# General
alias 'cd..'='cd_up'
# alias c="claude"
# alias claudee="nvm use default && claude" # in case the directory uses a weird node version
alias a="opencode"

alias tm="tmux"

#Vim
alias v="nvim"
alias vi="nvim"

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
alias gp="g pull"
alias gf="g fetch"
alias gfp="gf --prune"
alias gl="g log"
alias glt="gl --all --oneline --decorate-refs=refs/heads --graph"
alias glto="git log --graph --oneline --abbrev-commit --decorate  --first-parent"
alias gchp="g cherry-pick"

# --all
alias ga="g add"
alias gc="g commit"
alias gcm="gc -m"
alias gca="gc --amend"
alias gcan="gca --no-edit"
alias gm="g merge"
alias gu="g reset --soft HEAD~1"
alias gph="g push"
alias gpr=git_open_pr

# npm
# alias ni="npm install"
# alias nrd="npm run dev"
# alias nrl="npm run lint"
# alias nrf="npm run format"
# alias nrs="npm run build; npm run start"

alias y="yarn"

alias b="bun"

alias f="flutter"

# alias yreset="trash node_modules && yarn install && yarn start"

# alias nandroid="yarn mobile:android"

# alias nios="npm run ios"
# alias nandroid="npm run and"

# Docker
# alias d="docker"
# alias dlf="docker logs -f"

# kubectl
# alias kubectl="kubecolor"
# alias k="kubectl"
# alias kcc='k config current-context'
# alias kgp="echo 'Current context:' && kcc && kubectl get pods"
# alias klf=follow_logs_of_input_pod
# alias ke=psql_of_input_pod
# alias kpf=port_forward

# python
# alias p="python"
# alias wp="which python"
# alias pi="pip install -r requirements.txt"
# alias co="coverage run -m unittest discover"
#
# alias ap="autopep8 --in-place --recursive . --exclude venv --max-line-length 120"
# source_venv()

alias t="terraform"



# Easy recursive search in history fiiltering by current input text
# https://unix.stackexchange.com/a/97844
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end


# Do not share history accross tabs
unsetopt share_history

################################### FUNCTIONS ##################################

# Custom mkdir + cd command
mkcdir (){
	mkdir -p -- "$1" &&
	cd -P -- "$1"
}

# Custom variable with current date
precmd () {
	cdate=$(date +'%d-%m-%Y')
}


gclone_cd() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# Find and set branch name var if in git repository.
# TODO: prevent this from executing on non-git directories
git_branch_name() {
  branch=$(git symbolic-ref HEAD --quiet 2>/dev/null | awk 'BEGIN{FS="heads/"} {print $NF}');
  if [[ $branch == "" ]];
  then
    head=$(git rev-parse --short HEAD 2>/dev/null)
    if [[ $head == "" ]];
    then
    else
      echo '(detached '$head')'
    fi
  else
    echo '('$branch')'
  fi
}


git_tag() {
  tag=$(git tag --points-at 2> /dev/null) 
  if [[ $tag == "" ]];
  then
    :
  else
    echo '#('$tag')'
  fi
}


function cd_up() {
  cd $(printf "%0.s../" $(seq 1 $1 ));
}




alias raspberri="ssh -i /Users/berenar/.ssh/raspberri.pem berenar@raspberrypizero2w.local"


# VPN utilities

function vpn-connect {
/usr/bin/env osascript <<-EOF
tell application "System Events"
        tell current location of network preferences
                set VPN to service "MVST VPN" -- your VPN name here
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
                set VPN to service "MVST VPN" -- your VPN name here
                if exists VPN then disconnect VPN
        end tell
end tell
return
EOF
}




export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"


export PATH=/usr/local/bin:$PATH
export PATH="$PATH:/Users/berenar/development/flutter/bin"

# source /Users/berenar/.docker/init-zsh.sh || true # Added by Docker Desktop
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# bun completions
[ -s "/Users/berenar/.bun/_bun" ] && source "/Users/berenar/.bun/_bun"



eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# place this after nvm initialization!
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

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/berenar/.docker/completions $fpath)
autoload -Uz compinit
compinit

# opencode
export PATH=/Users/berenar/.opencode/bin:$PATH
