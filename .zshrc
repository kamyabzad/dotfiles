source ~/.zshrc_local

export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"

plugins=(git zsh-z fast-syntax-highlighting zsh-autosuggestions zsh-ai)

source $ZSH/oh-my-zsh.sh

export LC_ALL=en_US.UTF-8
FAST_HIGHLIGHT_STYLES[comment]='fg=cyan,bold'

alias vv="source ~/Projects/General/stuff/vv.sh"

export PATH=$PATH:~/.local/bin

# Go
export GOPATH=~/Projects/Go
export PATH=$PATH:$GOPATH/bin/
export GO11MODULE=on

# Rust
export PATH=$PATH:~/.cargo/bin/

# PostgreSQL
export PGDATA=/var/lib/postgres/data/

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


switch_to_monitor() {
    sed -i 's/100/150/' ~/.Xresources
    xrdb ~/.Xresources

    i3-msg restart
}

switch_to_laptop() {
    sed -i 's/150/100/' ~/.Xresources
    xrdb ~/.Xresources

    i3-msg restart
}

port2pid() {
  netstat -tlnp 2>/dev/null | awk -v port=":$1" '$4 ~ port {split($7, a, "/"); print a[1]}'
}


alias d="docker"
alias dc="docker-compose"
