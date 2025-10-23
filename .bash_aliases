# -*- mode: shell-script; -*-

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
alias back='cd $OLDPWD'

# File manipulation
alias cp='cp -ip'
alias cpv='rsync -ah --info=progress2'
alias mv='mv -i'

#Listing
alias ls='ls --ignore-backups --classify --color'
alias ll='ls -hl --group-directories-first'
alias lst='ll -rt'
alias lsd='ls -o | grep ^d'
if [ "$(command -v exa)" 2>&1 ]
then
    alias ls='exa --time-style long-iso'
    alias ll='ls -lg --group-directories-first'
    alias lst='ll -s modified'
    alias lsd='ll -D'
    alias lsg='ls --git-ignore'
    alias llg='ll --git-ignore'
    alias tree='ls --tree'
fi
alias l='ll'
alias la='ll -a'

# Colorize
alias diff='diff --color'

alias e='$EDITOR'
alias em='$VISUAL'

# Copy to/from X clipboard
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -o -selection c'

# Simpler mount output
alias mnt='mount | /bin/grep -E ^/dev | column -t'

# Better tools, if available
better () { echo "Consider installing $2 for a better $1"; }
[ "$(command -v utop)" 2>&1 ] && alias ocaml='utop' ||
        (better ocaml utop && [ "$(command -v rlwrap)" 2>&1 ] &&
             alias ocaml='rlwrap -c -R -pRed ocaml')
[ "$(command -v fdfind)" 2>&1 ] && alias fd='fdfind' || better fd fdfind
[ "$(command -v bat)" 2>&1 ] && alias cat='bat --theme=ansi' || better cat bat
[ "$(command -v prettyping)" 2>&1 ] && alias ping='prettyping --nolegend' ||
        better ping prettyping
[ "$(command -v htop)" 2>&1 ] && alias top='htop -u $USER' ||
        (better top htop && alias top='top -u $USER')
[ "$(command -v ncdu)" 2>&1 ] && alias du='ncdu --color dark -x --exclude .git' ||
        (better du ncdu && alias du='du -hx')
[ "$(command -v duf)" 2>&1 ] && alias df='duf --hide-fs tmpfs,devtmpfs,efivarfs --hide-mp /boot,/boot/efi,/var/snap/firefox/common/host-hunspell' ||
        (better df duf && alias df='df -h -x tmpfs')
[ "$(command -v rg)" 2>&1 ] && alias grep='rg -S -g !_build' ||
        (better grep rg && alias grep='grep --color=auto')

# Online services
alias weather='curl fr.wttr.in/?Fq'
alias meteo=weather

alias myip='curl -L ident.me'
alias myipv4='curl -L v4.ident.me'
alias myipv6='curl -L v6.ident.me'

# .xlsx splitter
alias xlsx2csv='libreoffice --convert-to csv:"Text - txt - csv (StarCalc)":44,34,UTF8,1,,0,false,true,false,false,false,-1'
