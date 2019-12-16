export SYSTEM=`uname`

SYSTEMPATH=/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/bin:/usr/bin/X11

if [ -d $HOME/bin ] ; then
  PATH=$HOME/bin:$PATH
fi

export PATH=$SYSTEMPATH:$PATH:.

cdpath=(~ ~/lib /)

export LANG="fr_FR.UTF-8"
export LC_COLLATE="C"
export HOSTNAME=`uname -n | /usr/bin/tr '[a-z]' '[A-Z]'`
export VERSION_CONTROL=numbered

export HISTCONTROL=ignoredups
export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTIGNORE="cd:ls:[bf]g:clear"
export HISTTIMEFORMAT="%d/%m/%Y - %T : "
shopt -s histappend
shopt -s cmdhist

set -o notify
shopt -s checkwinsize # Pour les terminaux redimmensionnables

umask 022

# PVM
export PVM_ROOT=/usr/lib/pvm3
export PVM_ARCH="LINUX64"
export PVM_RSH=`which ssh`
export PVM_TMP=/tmp
export PATH=$PVM_ROOT/bin:$PATH

# The prompt
BlueBG="$(tput setab 4)"
NC="$(tput sgr0)" # No Color

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ `command -v powerline-shell` && $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
else
    PS1="\[$BlueBG\]\u@\h \w\$\[$NC\] "
fi

# Completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Quelques variables d'environnement utiles en mode interactif uniquement
export ZIPOPT="-yrn .png:.gif:.tiff:.jpg:.Z:.gz:.zip"

export ALTERNATE_EDITOR='nano'
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c -a emacs'

# grepping for processes
psgrep() {
	if [ ! -z $1 ] ; then
		ps aux | grep $1 | grep -v grep # don't show the grep itself
	else
		echo "Provide a name to grep for!"
	fi
}

# Show those memory greedy guts
alias memusage='ps h -eo pmem,comm | sort -nr | head'

# Quelques alias...
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cp='cp -ip'
alias mv='mv -i'
#alias rm='rm -i'
alias la='ls -A'
alias ll='ls -Ahl'
alias lsd='ls -o | grep ^d'
alias ls='ls --ignore-backups --classify --color'
alias grep='grep --color=auto'
alias back='cd $OLDPWD'
alias diff='diff --color'

export LESS='-RiQ'
alias lessh='LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s" less -M '

#alias ocaml='ledit ocaml'
alias ocaml='rlwrap -c -R -pRed ocaml'

# Copy to/from X clipboard
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -o -selection c'

# Directory typos
shopt -s cdspell

# OPAM configuration
. /home/$USER/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# Colorisation des manpages
export LESS_TERMCAP_mb=$'\e[01;32m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline    env \

source ~/.private
