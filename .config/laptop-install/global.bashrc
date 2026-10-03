#
# /etc/global.bashrc
#

[[ $- != *i* ]] && return

colors() {
    local fgc bgc vals seq0

    printf "Color escapes are %s\n" '\e[${value};...;${value}m'
    printf "Values 30..37 are \e[33mforeground colors\e[m\n"
    printf "Values 40..47 are \e[43mbackground colors\e[m\n"
    printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

    # foreground colors
    for fgc in {30..37}; do
        # background colors
        for bgc in {40..47}; do
            fgc=${fgc#37} # white
            bgc=${bgc#40} # black

            vals="${fgc:+$fgc;}${bgc}"
            vals=${vals%%;}

            seq0="${vals:+\e[${vals}m}"
            printf "  %-9s" "${seq0:-(default)}"
            printf " ${seq0}TEXT\e[m"
            printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
        done
        echo; echo
    done
}

# Change the window title of X terminals
# case ${TERM} in
#     xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
#         PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
#         ;;
#     screen*)
#         PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
#         ;;
# esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    if [ "$HOSTNAME" = homeserver ]; then
        normalcolor='33m'
        rootcolorrr='36m'
    else
        normalcolor='32m'
        rootcolorrr='31m'
    fi


    if [[ ${EUID} == 0 ]] ; then
        PS1="\[\e[1;$rootcolorrr\][\u@\h\[\e[1;37m\] \w\[\e[1;$rootcolorrr\]]\$\[\e[00m\] "
    else
        PS1="\[\e[1;$normalcolor\][\u@\h\[\e[1;37m\] \w\[\e[1;$normalcolor\]]\$\[\e[00m\] "
    fi

    alias ls='ls --color=auto'
    alias grep='grep --colour=auto'
    alias egrep='egrep --colour=auto'
    alias fgrep='fgrep --colour=auto'
else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1='\u@\h \w \$ '
    else
        PS1='\u@\h \w \$ '
    fi
fi

unset use_color safe_term match_lhs sh

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
export HISTIGNORE=' *' # lines starting with ' ' will not be saved to history
# Write new history and load commands from other sessions before every prompt.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; history -n"

[[ -r "/usr/share/bash-completion/completions/git" ]] && . "/usr/share/bash-completion/completions/git"

dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

__git_complete dotfiles __git_main

server() {
    /usr/bin/git --git-dir="$HOME/.server/" --work-tree="$HOME" "$@"
}

__git_complete server __git_main


activate() {
    if [[ $1 == odoo* ]];
    then
        # ${1:4} removes 'odoo' from odoo12 leaving just the number
        if [ -z "$2" ]
        then
            echo "Specify odoo config file i.e. odoorc.conf"
            return
        fi
        export ODOO_CONFIG_FILE=$HOME"/Odoo/src/${1:4}/$2"
    fi
    . ~/.venv/$1/bin/activate
}

_venv_completer () {
    # https://askubuntu.com/questions/707610/bash-completion-for-custom-command-to-complete-static-directory-tree
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    k=0
    i="~/.venv" # the directory from where to start
    for j in $( compgen -f "$i/$cur" ); do # loop trough the possible completions
        [ -d "$j" ] && j="${j}/" || j="${j} " # if its a dir add a shlash, else a space
        COMPREPLY[k++]=${j#$i/} # remove the directory prefix from the array
    done
    return 0
}

complete -o nospace -F _venv_completer activate

config_pull(){(
    set -e # Fail early
    if [ -z "$1" ]
    then
        echo "Specify hostname"
        return
    fi
    rsync -avWPL "$1".ssh/ ~/.ssh
    rsync -avWPL "$1".bash_eternal_history ~/.bash_eternal_history
    rsync -avWPL "$1".psql_history ~/.psql_history
    rsync -avWPL "$1".python_history ~/.python_history
    rsync -avWPL "$1"VPN/ ~/VPN
)}

data_pull(){(
    set -e # Fail early
    if [ -z "$1" ]
    then
        echo "Specify hostname"
        return
    fi
    rsync -avWPL "$1"Projects/ ~/Projects
    rsync --exclude 'odoo-dbs' -avWPL "$1"Odoo/ ~/Odoo
    rsync --exclude 'lock' -avWPL "$1".thunderbird/ ~/.thunderbird
    rsync --exclude '*.log' -avWPL "$1".config/syncthing/ ~/.config/syncthing
)}


config_push(){(
    set -e # Fail early
    if [ -z "$1" ]
    then
        echo "Specify dir"
        return
    fi
    rsync -avWPL ~/.ssh/ $1/.ssh
    rsync -avWPL ~/.bash_eternal_history $1/.bash_eternal_history
    rsync -avWPL ~/.psql_history $1/.psql_history
    rsync -avWPL ~/.python_history $1/.python_history
    rsync -avWPL ~/VPN/ $1/VPN
)}

data_push(){(
    set -e # Fail early
    if [ -z "$1" ]
    then
        echo "Specify dir"
        return
    fi
    rsync --exclude 'lock' -avWPL ~/.thunderbird/ $1/.thunderbird
    rsync --exclude '*.log' -avWPL ~/.config/syncthing/ $1/.config/syncthing
    rsync -avWPL ~/School/ $1/School
    rsync -avWPL ~/Projects/ $1/Projects
    rsync --exclude 'odoo-dbs' -avWPL ~/Odoo/ $1/Odoo
)}


venv() {
    python3 -m venv ~/.venv/$1 ${@:2}
}


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


codex() {
    local SSH_AUTH_SOCK=""
    local SSH_AGENT_PID=""
    local GIT_SSH_COMMAND="ssh -o BatchMode=yes -o IdentityAgent=none -o IdentitiesOnly=yes -o IdentityFile=/dev/null"

    export SSH_AUTH_SOCK SSH_AGENT_PID GIT_SSH_COMMAND
    command codex "$@"
}


agy() {
    local SSH_AUTH_SOCK=""
    local SSH_AGENT_PID=""
    local GIT_SSH_COMMAND="ssh -o BatchMode=yes -o IdentityAgent=none -o IdentitiesOnly=yes -o IdentityFile=/dev/null"

    export SSH_AUTH_SOCK SSH_AGENT_PID GIT_SSH_COMMAND
    command agy "$@"
}

claude() {
    local SSH_AUTH_SOCK=""
    local SSH_AGENT_PID=""
    local GIT_SSH_COMMAND="ssh -o BatchMode=yes -o IdentityAgent=none -o IdentitiesOnly=yes -o IdentityFile=/dev/null"

    export SSH_AUTH_SOCK SSH_AGENT_PID GIT_SSH_COMMAND
    command claude "$@"
}


opencode() {
    local SSH_AUTH_SOCK=""
    local SSH_AGENT_PID=""
    local GIT_SSH_COMMAND="ssh -o BatchMode=yes -o IdentityAgent=none -o IdentitiesOnly=yes -o IdentityFile=/dev/null"

    export SSH_AUTH_SOCK SSH_AGENT_PID GIT_SSH_COMMAND
    command opencode "$@"
}


alias cls="tput reset && clear"
alias gitignore="cp ~/.config/odoo/.gitignore ."

PATH="~/.cargo/bin:~/.local/bin:$PATH"

[ -r ~/.bashrc ] && source ~/.bashrc

stty -ixon

export ANDROID_SDK=/home/elmeri/Android/Sdk
export VISUAL=vim
export EDITOR=vim
export FLASK_ENV=development
export ANSIBLE_DEBUG=0
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
