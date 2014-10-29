HISTFILESIZE=250000

shopt -s histappend

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export EDITOR=vim

alias "gdb=gdb -q"
alias "aria2cM=aria2c -x4 -k1M"
alias 'ls=ls --group-directories-first --color=auto'
alias epfl-connect='nmcli con up id "EPFL VPN"'
alias epfl-disconnect='nmcli con down id "EPFL VPN"'
# Looooooooooooooong alias coming up!
alias clang_complete_make="make CC='~/.vim/bundle/bin/cc_args.py gcc' CXX='~/.vim/bundle/bin/cc_args.py g++' -B"
alias wget-gzip="wget --header='accept-encoding: gzip'"
alias xclip="xclip -selection c"
alias vim-update="vim +BundleInstall +qall"

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
	local ENCRYPTED="$1"

	exec 3<<<""
	gpg --decrypt <"$ENCRYPTED" >/dev/fd/3
	vim /dev/fd/3
	gpg --encrypt --recipient 4018F537 <&3 >"$ENCRYPTED"
	exec 3>&-
}

# usage: ssh-tunnel FROM TO MACHINE
ssh-tunnel() {
	ssh -N -L$2:localhost:$1 $3
}

gnome-suspend() {
	dbus-send --system --print-reply \
		--dest="org.freedesktop.UPower" \
		/org/freedesktop/UPower \
		org.freedesktop.UPower.Suspend
}


help() {
	command help "$@"

	while [ ${1:0:1} = '-' ]; do
		case "$1" in
			--) shift; break ;;
			-*) shift ;;
		esac
	done

	echo
	echo "CUSTOM COMMANDS:"

	cat "$HOME/.bash_aliases" \
		| egrep '(^[^_][[:alnum:]-]*\(\))|(^# usage: )' \
		| sed -e 's/() {//' -e '/^help$/d' -e 's/^# usage: //' \
		| sort -r \
		| awk '++c[$1] && (NF > 1 || c[$1] == 1)' \
		| sort \
		| if [ $# -gt 0 ]; then
			grep "^$1" | sed 's/^\([^ ]*\) /\1: \1 /'
		else
			sed -e 's/^/ /'
		fi
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
		local FROM="me@${DOMAIN}"

		curl -s -k --user "api:$KEY" \
			"https://api.mailgun.net/v2/${DOMAIN}/messages" \
			-F from="$FROM" \
			-F to="$TO" \
			-F subject="$SUBJECT" \
			-F text='<-'
	else
		mail -s "$SUBJECT" "$TO"
	fi

}

if [ -f ~/.bash_local ]; then
	. ~/.bash_local
fi

