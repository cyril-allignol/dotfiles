export SYSTEM=`uname`

SYSTEMPATH=/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/bin:/opt

[ -d /snap/bin ] && SYSTEMPATH=$SYSTEMPATH:/snap/bin
[ -d $HOME/.cargo/bin ] && PATH=$HOME/.cargo/bin:$PATH
[ -d $HOME/go/bin ] && PATH=$HOME/go/bin:$PATH
[ -d $HOME/.local/bin ] && PATH=$HOME/.local/bin:$PATH
[ -d $HOME/.venv/default/bin ] && PATH=$HOME/.venv/default/bin:$PATH

export PATH=$SYSTEMPATH:$PATH:.

cdpath=(~ ~/lib /)

export LANG="fr_FR.UTF-8"
export LC_COLLATE="C"
export HOSTNAME=`uname -n | /usr/bin/tr '[a-z]' '[A-Z]'`
export VERSION_CONTROL=numbered

# History
export HISTCONTROL=ignoredups:erasedups:ignorespace
export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTIGNORE="cd:ls:[bf]g:clear"
export HISTTIMEFORMAT="%Y-%m-%d %T - "
shopt -s histappend
shopt -s cmdhist

set -o notify
shopt -s checkwinsize # For re-sizeable terminals

umask 022

# The prompt
# source ~/pureline/pureline ~/.pureline.conf
eval "$(starship init bash)"

# Completion
[ -f /etc/bash_completion ] && . /etc/bash_completion

_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip3

[ -f $HOME/.hledger-completion.bash ] && . $HOME/.hledger-completion.bash

# Quelques variables d'environnement utiles en mode interactif uniquement
export ZIPOPT="-yrn .png:.gif:.tiff:.jpg:.Z:.gz:.zip"

export ALTERNATE_EDITOR=''
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -nc -a emacs'
export PAGER='less'

export LESS='-RiQSFX'
eval $(lesspipe)

# Directory typos
shopt -s cdspell

# Where to cd?
shopt -s cdable_vars
export dl="$HOME/Téléchargements"
export cloud="$HOME/Cloud"

# OPAM configuration
. $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# Colorisation des manpages
export LESS_TERMCAP_mb=$'\e[01;32m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline    env \

[ -f $HOME/.private ] && . $HOME/.private
[ -f $HOME/.bash_aliases ] && . $HOME/.bash_aliases
[ -f $HOME/.bash_local ] && . $HOME/.bash_local

# FZF
[ -f $HOME/.fzf.bash ] && . $HOME/.fzf.bash
export FZF_DEFAULT_OPTS="--info=inline --cycle"
export FZF_DEFAULT_COMMAND='fdfind --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# Z for jumping around
[ -f $HOME/sw/z/z.sh ] && . $HOME/sw/z/z.sh
