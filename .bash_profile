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
eval "$(starship init bash)"

# Completion
test -f /etc/bash_completion && . $_

_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip3

test -f $HOME/.hledger-completion.bash && . $_

# Quelques variables d'environnement utiles en mode interactif uniquement
export ZIPOPT="-yrn .png:.gif:.tiff:.jpg:.Z:.gz:.zip"

export ALTERNATE_EDITOR=''
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -nc -a emacs'
export SUDO_EDITOR='emacsclient -c -a emacs'
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

# Python venv
export VIRTUAL_ENV_DISABLE_PROMPT=1
test -f $HOME/.venv/default/bin/activate && . $_

# Colorisation des manpages
export LESS_TERMCAP_mb=$'\e[01;32m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline    env \

test -f $HOME/.private && . $_
test -f $HOME/.bash_aliases && . $_
test -f $HOME/.bash_local && . $_

# FZF
test -f $HOME/.fzf.bash && . $_
export FZF_DEFAULT_OPTS="--info=inline --cycle --style full --height=80% --layout=reverse --margin=1"
export FZF_DEFAULT_COMMAND='fdfind --type f --exclude ".git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Nord theme for fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS
# export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
#     --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
#     --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
#     --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
#     --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

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

# if [ -f ~/sw/fzf-tab-completion/bash/fzf-bash-completion.sh ]
# then
#     source ~/sw/fzf-tab-completion/bash/fzf-bash-completion.sh
#     _fzf_bash_completion_loading_msg() { echo "${PS1@P}${READLINE_LINE}" | tail -n1; }
#     bind -x '"\t": fzf_bash_completion'
# fi

# find-in-file - usage: fif <searchTerm>
fif() {
    if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
    rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.
tm() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ $1 ]; then
        tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
    fi
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

fman() {
    man -k . | fzf -q "$1" --prompt='man> ' --preview $(echo {} | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man | col -bx | bat -l man -p --color always) | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

# Dotbare
test -f $HOME/sw/dotbare/dotbare.plugin.bash && . $_

# Z for jumping around
test -f $HOME/sw/z/z.sh && . $_
export _Z_DATA=~/.cache/z/.z
unalias z 2> /dev/null
z() {
    [ $# -gt 0 ] && _z "$*" && return
    cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# Forgit
test -f $HOME/sw/forgit/forgit.plugin.sh && . $_

# has
export HAS_ALLOW_UNSAFE=y
