# Show those memory greedy guts
alias memusage='ps h -eo pmem,comm | sort -nr | head'

# grepping for processes
psgrep() {
	if [ ! -z $1 ] ; then
		ps aux | grep $1 | grep -v grep # don't show the grep itself
	else
		echo "Provide a name to grep for!"
	fi
}

# Navigation
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cp='cp -ip'
alias cpv='rsync -ah --info=progress2'
alias mv='mv -i'
#alias rm='rm -i'
alias la='ls -A'
alias ll='ls -Ahl'
alias lsd='ls -o | grep ^d'
alias ls='ls --ignore-backups --classify --color'
alias back='cd $OLDPWD'

# Colorize
alias grep='grep --color=auto'
alias diff='diff --color'

#alias ocaml='ledit ocaml'
alias ocaml='rlwrap -c -R -pRed ocaml'

alias e='$EDITOR'
alias em='$VISUAL'

# Copy to/from X clipboard
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -o -selection c'

# Simpler mount output
alias mnt='mount | grep -E ^/dev | column -t'

# Better tools, if available
[ "$(command -v fdfind)" 2>&1 ] && alias fd='fdfind'
[ "$(command -v bat)" 2>&1 ] && alias cat='bat'
[ "$(command -v batcat)" 2>&1 ] && alias cat='batcat'
[ "$(command -v prettyping)" 2>&1 ] && alias ping='prettyping --nolegend'
[ "$(command -v htop)" 2>&1 ] && alias top='htop'
[ "$(command -v ncdu)" 2>&1 ] &&
    alias du='ncdu --color dark -rr -x --exclude .git'
