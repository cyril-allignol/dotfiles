
# Completion script for hledger.
# Created using a Makefile and real hledger.

# No set -e because this file is sourced and is not supposed to quit the current shell.
set -o pipefail

# Note: grep "^$wordToComplete" is (functional) not safe to use if the word
# contains regex special chars. But it might be no problem because of
# COMP_WORDBREAKS.

# Note: compgen and compopt is pretty complicated. Piping to
# grep "^$wordToComplete"
# seems like a hack - I'd rather use
# compgen ... -- "$wordToComplete"
# But what options to use? I don't want to use -W because it may exceed the
# maximum command line length. -C "cat file" is not working either. It would be
# best if compgen could read from stdin but it does not.

# Note: Working with bash arrays is nasty compared to editing a text file.
# Consider for example grepping an array or mapping a substitution on it.
# Therefore, we create temp files in RAM for completion suggestions (see below).

readonly _HLEDGER_COMPLETION_TEMPDIR=$(mktemp -d)

_hledger_completion_function() {
    #declare cmd=$1
    declare wordToComplete=$2
    declare precedingWord=$3

    declare subcommand
    for subcommand in "${COMP_WORDS[@]}"; do
	if grep -Fxqe "$subcommand" "$_HLEDGER_COMPLETION_TEMPDIR/commands.txt"; then
	    COMPREPLY+=( $(grep -h "^$wordToComplete" -- "$_HLEDGER_COMPLETION_TEMPDIR/options-$subcommand.txt") )
	    break
	fi
	subcommand=
    done

    if [[ -z $subcommand ]]; then

	declare completeFiles filenameSoFar
	case $precedingWord in
	    -f|--file|--rules-file)
		completeFiles=1
		filenameSoFar=$wordToComplete
		;;
	    =)
		completeFiles=1
		filenameSoFar=$wordToComplete
		;;
	esac

	if [[ -n $completeFiles ]]; then
	    #COMP_WORDBREAKS='= '
	    declare -a files
	    # This does not work because assignment to 'files' in the "pipe
	    # subshell" has no effect!
	    #compgen -df | grep "^$filenameSoFar" | readarray -t files

	    compopt -o filenames -o dirnames
	    readarray -t files < <(compgen -f -- "$filenameSoFar")
	    COMPREPLY=( "${files[@]}" )

	else
	    COMPREPLY+=( $(grep -h "^$wordToComplete" -- "$_HLEDGER_COMPLETION_TEMPDIR/commands.txt" "$_HLEDGER_COMPLETION_TEMPDIR/generic-options.txt") )
	fi

    else

	# Almost all subcommands accept [QUERY]
	# -> always add accounts to completion list

	# TODO Get ledger file from -f --file arguments from COMP_WORDS and pass it to
	# the 'hledger accounts' call. Note that --rules-file - if present - must also
	# be passed!

	declare -a accounts
	readarray -t accounts < <({ cat "$_HLEDGER_COMPLETION_TEMPDIR/query-filters.txt"; hledger accounts --flat; } | grep "^$wordToComplete")
	compopt -o nospace
	COMPREPLY+=( "${accounts[@]}" )
	# Special characters (e.g. '-', ':') are allowed in account names.
	# Account names with spaces must be still be quoted (e.g. '"Expens')
	# for completion. Setting COMP_WORDBREAKS='' would not help here!
	COMP_WORDBREAKS=' '

    fi

}

_hledger_extension_completion_function() {
    declare cmd=$1

    # Change parameters and arguments and call the
    # normal hledger completion function.
    declare extensionName=${cmd#*-}
    export -a COMP_WORDS=( "hledger" "$extensionName" "${COMP_WORDS[@]:1}" )
    #echo; echo "debug: ${COMP_WORDS[@]}"
    shift
    _hledger_completion_function "hledger" "$@"
}

# Register completion function for hledger:
complete -F _hledger_completion_function hledger

# Register completion functions for hledger extensions:
complete -F _hledger_extension_completion_function hledger-ui
complete -F _hledger_extension_completion_function hledger-web

# Include lists of commands and options generated by the Makefile using the
# m4 macro processor.
# Included files must have exactly one newline at EOF to prevent weired errors.

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/commands.txt"
add
import
check-dates
check-dupes
close
diff
rewrite
balancesheet
balancesheetequity
cashflow
incomestatement
roi
accounts
activity
balance
commodities
files
prices
print
print-unique
register
register-match
stats
tags
test
help
equity
bs
bse
cf
is
ui
web
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/query-filters.txt"
not:
acct:
amt:
amt:<
amt:<=
amt:>
amt:>=
code:
cur:
desc:
date:
date2:
depth:
note:
payee:
real:
real:0
status:
status:!
status:*
tag:
inacct:
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/generic-options.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT




cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-add.txt"
--alias
--anon
--debug
--file
--help
--ignore-assertions
--no-new-accounts
--pivot
--rules-file
--separator
--version
-I
-f
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-import.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--dry-run
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--new
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
-x
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-check-dates.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--strict
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-check-dupes.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-close.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--closing
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--opening
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-5
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-diff.txt"
--alias
--anon
--debug
--file
--help
--ignore-assertions
--pivot
--rules-file
--separator
--version
-I
-f
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-rewrite.txt"
--add-posting
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--diff
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-1
-2
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-balancesheet.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-balancesheetequity.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-cashflow.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-incomestatement.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-roi.txt"
--alias
--anon
--auto
--aux-date
--begin
--cashflow
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--inv
--investment
--market
--monthly
--pending
--period
--pivot
--pnl
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-accounts.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--declared
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--tree
--unmarked
--used
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-activity.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-balance.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--budget
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--invert
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--transpose
--tree
--unmarked
--value
--version
--weekly
--yearly
-1
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-commodities.txt"
--alias
--anon
--debug
--file
--help
--ignore-assertions
--pivot
--rules-file
--separator
--version
-I
-f
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-files.txt"
--alias
--anon
--debug
--file
--help
--ignore-assertions
--pivot
--rules-file
--separator
--version
-I
-f
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-prices.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--costs
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--inverted-costs
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-print.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--explicit
--file
--forecast
--help
--ignore-assertions
--market
--match
--monthly
--new
--output-file
--output-format
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-O
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-m
-o
-p
-x
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-print-unique.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-register.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--historical
--ignore-assertions
--invert
--market
--monthly
--output-file
--output-format
--pending
--period
--pivot
--quarterly
--real
--related
--rules-file
--separator
--unmarked
--value
--version
--weekly
--width
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
-r
-w
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-register-match.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-stats.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--output-file
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-tags.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-test.txt"
--debug
--help
--version
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-help.txt"
--cat
--help
--info
--man
--pager
-h
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-equity.txt"
--alias
--anon
--auto
--aux-date
--begin
--cleared
--closing
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--forecast
--help
--ignore-assertions
--market
--monthly
--opening
--pending
--period
--pivot
--quarterly
--real
--rules-file
--separator
--unmarked
--value
--version
--weekly
--yearly
-5
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-bs.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-bse.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-cf.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-is.txt"
--alias
--anon
--auto
--aux-date
--average
--begin
--change
--cleared
--cost
--cumulative
--daily
--date2
--debug
--depth
--drop
--empty
--end
--exchange
--file
--flat
--forecast
--format
--help
--historical
--ignore-assertions
--market
--monthly
--no-elide
--no-total
--output-file
--output-format
--pending
--period
--pivot
--pretty-tables
--quarterly
--real
--row-total
--rules-file
--separator
--sort-amount
--tree
--unmarked
--value
--version
--weekly
--yearly
-A
-B
-C
-D
-E
-H
-I
-M
-N
-O
-P
-Q
-R
-S
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-o
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-ui.txt"
--alias
--anon
--auto
--aux-date
--begin
--change
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--flat
--forecast
--future
--help
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--quarterly
--real
--register
--rules-file
--separator
--theme
--tree
--unmarked
--value
--version
--watch
--weekly
--yearly
-B
-C
-D
-E
-F
-I
-M
-N
-P
-Q
-R
-T
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT

cat <<TEXT > "$_HLEDGER_COMPLETION_TEMPDIR/options-web.txt"
--alias
--anon
--auto
--aux-date
--base-url
--begin
--capabilities
--capabilities-header
--cleared
--cost
--daily
--date2
--debug
--depth
--empty
--end
--exchange
--file
--file-url
--forecast
--help
--host
--ignore-assertions
--market
--monthly
--pending
--period
--pivot
--port
--quarterly
--real
--rules-file
--separator
--server
--unmarked
--value
--version
--weekly
--yearly
-B
-C
-D
-E
-I
-M
-N
-P
-Q
-R
-U
-V
-W
-X
-Y
-b
-e
-f
-h
-p
TEXT
