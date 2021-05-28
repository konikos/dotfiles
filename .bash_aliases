export DOTNET_CLI_TELEMETRY_OPTOUT=1

HISTSIZE=2000
HISTFILESIZE=25000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend
shopt -s extglob

declare -r __col_lgrey='\e[38;5;247m'
declare -r __ps1_col_red='\[\e[38;5;197m\]'
declare -r __ps1_col_green='\[\e[38;5;112m\]'
declare -r __ps1_col_lgrey="\[$__col_lgrey\]"
declare -r __ps1_col_cyan='\[\e[38;5;81m\]'
declare -r __ps1_col_reset='\[\e[m\]'

# helper for PS1 that prints the current virtualenv, if any
__ps_venv() {
	if [[ -n $VIRTUAL_ENV ]]; then
		printf "(%s) " "$(basename "$VIRTUAL_ENV")"
	fi
}

# helper for PS1 that prints the current dir's git info, if any
__ps_git() {
	local mark local remote behind ahead
	git for-each-ref --format="%(HEAD) %(refname:short) %(upstream:short) %(objectname:short)" refs/heads 2>/dev/null | \
		grep -m1 '^\*' | while IFS=' ' read -r mark local remote sha1
		do
			printf "%s (%s)" "$sha1" "$local"
			if ! git diff-index --quiet HEAD --; then
				printf "*"
			fi

			[[ -z $remote ]] && continue
			git rev-list --count --left-right "${remote}..${local}" -- | \
				while read -r behind ahead; do
					if [[ $behind -ne 0 ]]; then
						printf " ▾%d" "$behind"
					fi
					if [[ $ahead -ne 0 ]]; then
						printf " ▴%d" "$ahead"
					fi
				done
		done
}

__ps_time() {
	# shellcheck disable=SC2183
	printf '%(%H:%M)T'
}

__ps_widgets_array=( \
	__ps_time \
	__ps_git \
)

__ps_exit_code() {
	printf '^%d' "$__EXIT_CODE"
}

__ps_widgets_show() {
	for w in "${__ps_widgets_array[@]}"; do
		printf " "
		$w
	done
}

__ps_opt_hostname() {
	if [[ -n $SSH_CLIENT ]] || [[ -n $SSH_TTY ]]; then
		printf "%s " "$HOSTNAME"
	fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=yes
PS1="\\n${__ps1_col_cyan}\${debian_chroot:+(\$debian_chroot)}\\w${__ps1_col_reset}${__ps1_col_lgrey}\$(__ps_widgets_show)${__ps1_col_reset}\n\$(__ps_venv)${__ps1_col_lgrey}\$(__ps_opt_hostname)\\\$${__ps1_col_reset} "

for EDITOR in nvim vim vi nano pico; do
	if which "$EDITOR" &>/dev/null; then
		break
	fi
done
export EDITOR

PATH="$PATH:$HOME/bin"

__fzf-git-widget() {
	FZF_CTRL_T_COMMAND="command git status --porcelain | cut -c 4-" fzf-file-widget
}

bind -x '"\C-g": "__fzf-git-widget"'

alias gdb='gdb -q'
alias aria2cM='aria2c -x4 -k1M'
alias ls='ls --group-directories-first --color=auto'
alias wget-gzip='wget --header="accept-encoding: gzip"'
alias xclip='xclip -selection c'
alias xc='xclip -selection c'
alias xp='xclip -selection c -out'
alias vim-update='vim +PlugInstall +PlugUpdate +qall'
alias nvim-update='nvim +PlugInstall +PlugUpdate +UpdateRemotePlugins +qall'
alias g=git
alias ggl='git graph-log -n10'
alias d=docker
alias dcl='docker container list'
alias dck='docker container kill'
alias agi='ag --ignore-case'
alias ssh-key-only='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no'

alias ':h=:help'
alias ':reload=. ~/.bash_aliases'
alias ':r=:reload'

# Prints help for functions which are defined in ~/.bash_aliases
# usage: :help [FUNCTION]
:help() {
	local columnize="pr --columns=2 --omit-header"
	if ! type pr >/dev/null 2>&1; then
		columnize=cat
	fi

	cat "$HOME/.bash_aliases" "$HOME/.bash_local" \
		| egrep '(^[^_][[:alnum:]-]*\(\))|(^# usage: )' \
		| sed -e 's/() {//' -e 's/^# usage: //I' \
		| sort -r \
		| awk '!/^_/ && ++c[$1] && (NF > 1 || c[$1] == 1)' \
		| sort \
		| if [[ $# -gt 0 ]]; then
			grep "^$1" | sed 's/^\([^ ]*\) /\1: \1 /'
		else
			sed -e 's/^/ /' | $columnize
		fi
}

# usage: apt-urls PACKAGE..
apt-urls() {
	apt-get install --reinstall -qq --print-uris "$@" | cut -d ' ' -f 1 | sed "s/^'\(.*\)'$/\1/g"
}

# usage: pdf-crop [PDF..]
pdf-crop() {
	for f in "$@"; do
		briss -s "$f"
	done
}

# usage: pdf-cat [PDF..]
pdf-cat() {
	pdftk "$@" cat output -
	# OR:
	# gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=- "$@"
}

# usage: find-ugly [FILE_OR_DIR..]
find-ugly() {
	find "$@" -type f -print0 \
		| xargs -0 gawk 'length() >= 80 { print FILENAME ":" FNR ":\t" $0}'
}

# usage: pdf-title-fix [PDF..]
pdf-title-fix() {
	ls -1 "$@" | while read fname; do
		SRC="$fname"
		DEST="$fname.new.pdf"
		NEW_TITLE=$(basename "${fname%.*}")
		echo -e "InfoKey: Title\nInfoValue: $NEW_TITLE" \
			| pdftk "$fname" update_info - output "$DEST";
		mv "$DEST" "$SRC"
	done
}

# usage: finddup [DIR..]
# Find duplicate files, based on size first, then MD5 hash
finddup() {
	find "$@" -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate
}

incognito() {
	HISTFILE=/dev/null
}

# usage: v [-c] [VENV=./tmp/venv] [CREATE_ARGS..]
# usage: v -t [-c] VENV [CREATE_ARGS..]
v() {
	local OPTIND
	local CREATE=false
	local TEMP=false

	# process options
	while getopts "cth" opt; do
		case "$opt" in
			c) CREATE=true ;;
			t) TEMP=true ;;
			h)
				echo "v [-c] [VENV=./tmp/venv]" 1>&2
				echo "v -t [-c] VENV" 1>&2
				return 0
				;;
			?)
				echo "v: error $opt" 1>&2
				return 1
				;;
		esac
	done
	shift $((OPTIND-1))

	local VENV="$1"; shift
	if $TEMP; then
		if [ -z "$VENV" ]; then
			echo "v: VENV should be provided if used with -t" 1>&2
			return 1
		fi
		VENV="${HOME}/tmp/venv/$VENV"
	elif [ -z "$VENV" ]; then
		VENV=./tmp/venv
	fi

	local ACTIVATE="${VENV}/bin/activate"
	if $CREATE; then
		if [ -f "${ACTIVATE}" ]; then
			echo "v: virtualenv already exists at $VENV" 1>&2
			return 1
		fi
		virtualenv "$@" "$VENV"
	fi

	. "$ACTIVATE"
}


WARP9_PORT=27401

# usage: warp9-send HOST
warp9-send() {
	nc -w 2 "$1" "$WARP9_PORT"
}

# usage: warp9-receive
warp9-receive() {
	nc -l -p "$WARP9_PORT"
}


# usage: http-serve [DIR [HOST] [PORT]]
http-serve() {
	DIR=$(pwd)
	HOST=127.0.0.1
	PORT=8080
	[ -z "$1" ] || DIR="$1"
	shift
	[ -z "$1" ] || HOST="$1"
	shift
	[ -z "$1" ] || PORT="$1"
	shift

	if [[ $HOST = "0.0.0.0" ]] && type python2 >/dev/null 2>&1; then
		(cd "$DIR" && python -m SimpleHTTPServer "$PORT")
	elif type python3 >/dev/null 2>&1; then
		python3 -m http.server "$PORT" --bind "$HOST"
	else
		echo "ERROR: Could not find python2 or python3" >&2
		return 1
	fi
}

# usage: gpg-edit FILE
gpg-edit() {
	local recipient_key="4018F537"
	local input_file="$1"

	exec 3<<<""

	if [[ -f "$input_file" ]]; then
		if ! gpg --decrypt <"$input_file" >/dev/fd/3; then
			echo 'gpg-edit aborted' >&2
			return 1
		fi
	fi

	if ! ${EDITOR=vim} /dev/fd/3; then
		return 1
	fi
	gpg --encrypt --recipient "$recipient_key" <&3 >"$input_file"
	exec 3>&-
}

# usage: ssh-tunnel LOCAL_PORT MACHINE MACHINE_PORT
ssh-tunnel() {
	ssh -v -N -L"$1:localhost:$3" "$2"
}

# usage: sbt-main MAIN_CLASS
# Run sbt with MAIN_CLASS set as the default main class.
sbt-main() {
	local CLASS="$1"; shift
	sbt '; set mainClass in (Compile, run) := Some("'"$CLASS"'")' "$@"
}

# usage: mailme SUBJECT <BODY
mailme() {
	if [ "$#" -lt 1 ]; then
		echo "usage: mailme SUBJECT <BODY" 1>&2
		return 1
	fi

	local -r to='kokolakisnikos@gmail.com'
	local -r subject="[mailme] $1"

	if [[ -f ~/.mailgunkey ]]; then
		local hostname
		hostname=$(hostname -s)
		local mailgun_key=$(cat ~/.mailgunkey)
		local domain='notifications.konikos.com'
		local from="${USER}@${hostname} <mailme-+${USER}-${hostname}@${domain}>"

		curl -s -k --user "api:$mailgun_key" \
			"https://api.mailgun.net/v2/${domain}/messages" \
			-F from="$from" \
			-F to="$to" \
			-F subject="$subject" \
			-F text='<-'
	elif which mail >/dev/null; then
		mail -s "$subject" "$to"
	else
		echo 'ERROR: mailgunkey is missing and "mail" is not installed' 1>&2
		return 1
	fi
}

sprunge() {
	curl -F 'sprunge=<-' "http://sprunge.us"
}

sprunge-copy() {
	sprunge | xclip
}

# usage: py-mkpkg PACKAGE_NAME
# Creates the dir structure and the required __init__.py files for a python
# package
py-mkpkg() {
	local pkg="$1"
	local pkg_parts

	IFS='.' read -a pkg_parts <<<"$pkg"
	for part in "${pkg_parts[@]}"; do
		if ! grep -q '^[_A-Za-z][_A-Za-z0-9]*$' <<<"$part"; then
			echo "Error: Not a valid identifier: \`$part'"
			return 1
		fi
	done

	local pkg_path="."
	for part in "${pkg_parts[@]}"; do
		pkg_path="$pkg_path/$part"
		mkdir -p "$pkg_path"
		touch "$pkg_path/__init__.py"
	done
}


# Title changing functionality {{{
case "$TERM" in
	xterm*|rxvt*)
		term_change_title() {
			echo -ne "\033]0;${1}\007"
		}
		;;
	screen*)
		term_change_title() {
			printf '\ek%s\e\\' "$1"
		}
		;;
	*)
		term_change_title() {
			:
		}
esac


# __short_path PATH
__short_path() {
	local path=$1

	if [[ "${#path}" -lt 12 ]]; then
		echo "$path"
		return
	fi

	local components=
	IFS='/' read -r -a components <<< "$path"

	for ((i=0; i<${#components[@]}; i++)); do
		local component="${components[$i]}"

		if [[ $i -eq 0 && ${component} = "" ]]; then
			continue
		fi

		if [[ $i -ne 0 ]]; then
			echo -n '/'
		fi

		if (($i >= ${#components[@]} - 2)); then
			echo -n "${component}"
		else
			echo -n "${component:0:1}"
		fi
	done

	echo
}


__change_title_postexec() {
	local unexpanded_pwd="${PWD}"
	unexpanded_pwd="${unexpanded_pwd/#${HOME}\/src/@}"
	unexpanded_pwd="${unexpanded_pwd/#${HOME}/\~}"

	term_change_title "\$ $(__short_path "${unexpanded_pwd}")"
}

PROMPT_COMMAND="__change_title_postexec; $PROMPT_COMMAND"


__change_title_preexec() {
    if [ -n "$COMP_LINE" ]; then
		# This happened during during autocompletion
		return
	fi

    if [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ]; then
		return
	fi

    local exe=$(HISTTIMEFORMAT= history 1 | awk '{ print $2 }')
	term_change_title "$exe"

	if [[ "$exe" = "fg" ]]; then
		exe=$(jobs -s | tail -n1 | awk '{ print $3 }') || return
		term_change_title "$exe"
	fi
}

trap '__change_title_preexec "$_"' DEBUG
# }}}


if [ -f ~/.bash_local ]; then
	. ~/.bash_local
fi

# usage: _1
# Prints the first field in a space-delimited line
_1() {
	awk '{ print $1 }'
}

# usage: _2
# Prints the second field in a space-delimited line
_2() {
	awk '{ print $2 }'
}

# usage: _3
# Prints the third field in a space-delimited line
_3() {
	awk '{ print $3 }'
}

# usage: _n N
# Prints the N-th field in a space-delimited line
_n() {
	if ! [[ $1 =~ ^[0-9]+$ ]]; then
		echo "${FUNCNAME[0]}: provided column is not number: $1" >&2
		return 1
	fi
	awk -v "col=${1}" '{ print $col }'
}

# usage: ssh-tmux HOST
ssh-tmux() {
	ssh -t "$@" tmux new-session -A -s default
}
