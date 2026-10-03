# Shared interactive Bash settings installed as /etc/global.bashrc.

[[ $- != *i* ]] && return

# Prompt and colors

# Color ls output using ~/.dir_colors, falling back to /etc/DIR_COLORS.
if type -P dircolors >/dev/null; then
    if [[ -f ~/.dir_colors ]]; then
        eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]]; then
        eval $(dircolors -b /etc/DIR_COLORS)
    fi
fi

# Use different prompt colors on homeserver and for root shells.
if [ "$HOSTNAME" = homeserver ]; then
    normalcolor='33m'
    rootcolorrr='36m'
else
    normalcolor='32m'
    rootcolorrr='31m'
fi

if [[ ${EUID} == 0 ]]; then
    PS1="\[\e[1;$rootcolorrr\][\u@\h\[\e[1;37m\] \w\[\e[1;$rootcolorrr\]]\$\[\e[00m\] "
else
    PS1="\[\e[1;$normalcolor\][\u@\h\[\e[1;37m\] \w\[\e[1;$normalcolor\]]\$\[\e[00m\] "
fi

# Terminal and shell behavior

# Allow local root processes to connect to this user's X server.
xhost +local:root > /dev/null 2>&1

# After sudo, Tab suggests command names (-c) and filenames (-f).
complete -cf sudo

# Refresh terminal dimensions after each foreground command.
shopt -s checkwinsize

# Expand aliases when reading commands from this interactive shell.
shopt -s expand_aliases
unset sh

# Aliases

alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias cls="tput reset && clear"
alias gitignore="cp ~/.config/odoo/.gitignore ."
alias code="vscodium"

# Command history

# Append history on exit instead of replacing the history file.
shopt -s histappend

# Empty sizes leave both in-memory and saved history unlimited.
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Use a separate file so other Bash sessions do not truncate this history.
export HISTFILE=~/.bash_eternal_history
export HISTIGNORE=' *' # Ignore commands that begin with a space.
# Save this session's new commands and read commands from other sessions.
PROMPT_COMMAND="history -a; history -n"

# Git repositories and submodules

# bash_completion loads Git's completion only when Git is first completed.
# Load it now so __git_complete can register these two Git wrappers.
[[ -r "/usr/share/bash-completion/completions/git" ]] && . "/usr/share/bash-completion/completions/git"

dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

__git_complete dotfiles __git_main

server() {
    /usr/bin/git --git-dir="$HOME/.server/" --work-tree="$HOME" "$@"
}

__git_complete server __git_main

# Remove a submodule or reset the working tree and all submodules.
rm_submodule() {
    git submodule deinit -f -- "$1"
    rm -rf ".git/modules/a/$1"
    git rm -rf "$1"
}

hard_reset_submodules() {
    git clean -xfdf
    git submodule foreach --recursive git clean -xfdf
    git reset --hard
    git submodule foreach --recursive git reset --hard
    git submodule update --init --recursive
}

# Python virtual environments

# Activate a named ~/.venv environment; Odoo environments also select a config.
activate() {
    if [[ $1 == odoo* ]]; then
        # ${1:4} removes 'odoo' from odoo12, leaving the version number.
        if [ -z "$2" ]; then
            echo "Specify odoo config file i.e. odoorc.conf"
            return
        fi
        export ODOO_CONFIG_FILE=$HOME"/Odoo/src/${1:4}/$2"
    fi
    . ~/.venv/$1/bin/activate
}

_venv_completer() {
    # Suggest names from ~/.venv/ after typing "activate ".
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    k=0
    i="~/.venv" # The directory from which to complete.
    for j in $( compgen -f "$i/$cur" ); do
        [ -d "$j" ] && j="${j}/" || j="${j} "
        COMPREPLY[k++]=${j#$i/}
    done
    return 0
}

complete -o nospace -F _venv_completer activate

venv() {
    python3 -m venv ~/.venv/$1 ${@:2}
}

# Machine-to-machine transfers

config_pull() { (
    set -e
    if [ -z "$1" ]; then
        echo "Specify hostname"
        return
    fi
    rsync -avWPL "$1".ssh/ ~/.ssh
    rsync -avWPL "$1".bash_eternal_history ~/.bash_eternal_history
    rsync -avWPL "$1".psql_history ~/.psql_history
    rsync -avWPL "$1".python_history ~/.python_history
    rsync -avWPL "$1"VPN/ ~/VPN
); }

config_push() { (
    set -e
    if [ -z "$1" ]; then
        echo "Specify dir"
        return
    fi
    rsync -avWPL ~/.ssh/ $1/.ssh
    rsync -avWPL ~/.bash_eternal_history $1/.bash_eternal_history
    rsync -avWPL ~/.psql_history $1/.psql_history
    rsync -avWPL ~/.python_history $1/.python_history
    rsync -avWPL ~/VPN/ $1/VPN
); }

data_pull() { (
    set -e
    if [ -z "$1" ]; then
        echo "Specify hostname"
        return
    fi
    rsync -avWPL "$1"Projects/ ~/Projects
    rsync --exclude 'odoo-dbs' -avWPL "$1"Odoo/ ~/Odoo
    rsync --exclude 'lock' -avWPL "$1".thunderbird/ ~/.thunderbird
    rsync --exclude '*.log' -avWPL "$1".config/syncthing/ ~/.config/syncthing
); }

data_push() { (
    set -e
    if [ -z "$1" ]; then
        echo "Specify dir"
        return
    fi
    rsync --exclude 'lock' -avWPL ~/.thunderbird/ $1/.thunderbird
    rsync --exclude '*.log' -avWPL ~/.config/syncthing/ $1/.config/syncthing
    rsync -avWPL ~/School/ $1/School
    rsync -avWPL ~/Projects/ $1/Projects
    rsync --exclude 'odoo-dbs' -avWPL ~/Odoo/ $1/Odoo
); }

# AI command wrappers

# Hide the SSH agent and prevent Git from trying an identity while these tools run.
_without_ssh_agent() {
    local SSH_AUTH_SOCK=""
    local SSH_AGENT_PID=""
    local GIT_SSH_COMMAND="ssh -o BatchMode=yes -o IdentityAgent=none -o IdentitiesOnly=yes -o IdentityFile=/dev/null"

    export SSH_AUTH_SOCK SSH_AGENT_PID GIT_SSH_COMMAND
    command "$@"
}

codex() {
    _without_ssh_agent codex "$@"
}

claude() {
    _without_ssh_agent claude "$@"
}

agy() {
    _without_ssh_agent agy "$@"
}

opencode() {
    _without_ssh_agent opencode "$@"
}

# User settings and environment

PATH="~/.cargo/bin:~/.local/bin:$PATH"

# Apply per-user Bash customizations after the shared settings.
[ -r ~/.bashrc ] && source ~/.bashrc

# Let Ctrl+S and Ctrl+Q reach applications instead of pausing terminal output.
stty -ixon

# Session environment.
export ANDROID_SDK=/home/elmeri/Android/Sdk
export VISUAL=vim
export EDITOR=vim
export FLASK_ENV=development
export ANSIBLE_DEBUG=0
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
