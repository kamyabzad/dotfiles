# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"


HYPHEN_INSENSITIVE="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-z fast-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration
export LC_ALL=en_US.UTF-8

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
alias vv="source ~/Projects/General/stuff/vv.sh"

export PATH=$PATH:~/.local/bin

# Spark
export SPARK_HOME=~/.spark-3.1.1-bin-hadoop2.7
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$PATH:$SPARK_HOME/bin
export PATH=$PATH:$JAVA_HOME/jre/bin
export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
export PYSPARK_PYTHON=python

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
alias resolv="sudo cp ~/.resolv.conf /etc/resolv.conf"

switch_to_laptop() {
    cd ~/Projects/General/dotfiles
    git switch master

    cd /usr/lib/firefox
    sed -i 's/pref("layout.css.devPixelsPerPx", "2.5")/pref("layout.css.devPixelsPerPx", "1")/' firefox.cfg

    i3-msg restart
}


switch_to_monitor() {
    cd ~/Projects/General/dotfiles
    git switch 43-inch-4k-monitor

    cd /usr/lib/firefox
    sed -i 's/pref("layout.css.devPixelsPerPx", "1");/pref("layout.css.devPixelsPerPx", "2.5");/' firefox.cfg

    i3-msg restart
}
