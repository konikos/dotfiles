HISTSIZE=2000
HISTFILESIZE=25000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export EDITOR=vim

PATH="$PATH:$HOME/bin"

alias "gdb=gdb -q"
alias "aria2cM=aria2c -x4 -k1M"
alias 'ls=ls --group-directories-first --color=auto'
alias wget-gzip="wget --header='accept-encoding: gzip'"
alias xclip="xclip -selection c"
alias vim-update="vim +PlugInstall +PlugUpdate +qall"
alias nvim-update="nvim +PlugInstall +PlugUpdate +UpdateRemotePlugins +qall"

alias ':h=:help'
alias ':reload=. ~/.bash_aliases'
alias ':r=:reload'


alias g=git


# Prints help for functions which are defined in ~/.bash_aliases
# usage: :help [FUNCTION]
:help() {
	local columnize="pr --columns=2 --omit-header"
	if ! type pr >/dev/null 2>&1; then
		columnize=cat
	fi

	cat "$HOME/.bash_aliases" \
		| egrep '(^[^_][[:alnum:]-]*\(\))|(^# usage: )' \
		| sed -e 's/() {//' -e 's/^# usage: //I' \
		| sort -r \
		| awk '++c[$1] && (NF > 1 || c[$1] == 1)' \
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

# usage: mobi2epub [EPUB..]
mobi2epub() {
	ls -1 "$@" | while read mobi; do
		EPUB="${mobi%.*}.epub"
		ebook-convert "$mobi" "$EPUB" --output-profile nook
	done
}

# usage: svg2ico SVG
svg2ico() {
	echo "Not finished"
	return
	SRC="$1"
	SRC_BASE="$(basename "$SRC")"
	DEST="$(dirname "$SRC")"/"${SRCBASE%.*}_%.3d.png"

	for d in 256 128 48 32 16; do
		rsvg-convert -w $d -h $d "$SRC" >ipod_$(printf "%.3d" $d).png;
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


# usage: super-compress ARCHIVE_NAME FILE..
super-compress() {
	local ARCHIVE="$1"
	shift
	7za a -t7z  -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$ARCHIVE" "$@"
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


# usage: serve-http [DIR [PORT]]
http-serve() {
	DIR=$(pwd)
	PORT=8080
	[ -z "$1" ] || DIR="$1"
	shift
	[ -z "$1" ] || PORT="$1"
	shift

	(cd "$DIR" && python -m SimpleHTTPServer "$PORT")
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

gnome-suspend() {
	dbus-send --system --print-reply \
		--dest="org.freedesktop.UPower" \
		/org/freedesktop/UPower \
		org.freedesktop.UPower.Suspend
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

	local TO='kokolakisnikos@gmail.com'
	local SUBJECT="[mailme] $1"

	if [[ -f ~/.mailgunkey ]]; then
		local KEY=$(cat ~/.mailgunkey)
		local DOMAIN='notifications.konikos.com'
		local FROM="${USER}@$(hostname -s) <me@${DOMAIN}>"

		curl -s -k --user "api:$KEY" \
			"https://api.mailgun.net/v2/${DOMAIN}/messages" \
			-F from="$FROM" \
			-F to="$TO" \
			-F subject="$SUBJECT" \
			-F text='<-'
	elif which mail >/dev/null; then
		mail -s "$SUBJECT" "$TO"
	else
		echo "ERROR: mailgunkey is missing and \'mail' is not installed" 1>&2
		return 1
	fi

}

sprunge() {
	curl -F 'sprunge=<-' "http://sprunge.us"
}

sprunge-copy() {
	sprunge | xclip
}

# usage: randstr [LEN [CHARS='_A-Za-z0-9@#$%^&*()=-']]
# Generate a random string of length LEN using
randstr() {
	local len=$1
	if [[ -z $len ]]; then
		len=24
	elif [[ $len -lt 1 ]]; then
		echo "usage: randstr [LEN [CHARS]]" 1>&2
		echo " LEN should be > 0" 1>&2
		return 1
	fi

	local chars=$2
	if [[ ! $chars ]]; then
		chars='_A-Za-z0-9@#$%^&*()=-'
	fi

	LC_CTYPE=C < /dev/urandom tr -dc "$chars" | head -c"${1:-$len}"; echo
}

# usage: sumlines <INTEGERS
# Sums a list of integers
sumlines() {
	awk '{ sum += $1 } END { print sum }'
}

# usage: wget-mirror URL
# Mirror the contents of website under URL
wget-mirror() {
	wget \
		--page-requisites \
		--user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0" \
		--mirror --convert-links --adjust-extension \
		--page-requisites --no-parent --continue \
		"$@"
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
	unexpanded_pwd="${unexpanded_pwd/#${HOME}\/Projects/@}"
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
