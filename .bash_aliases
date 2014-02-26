HISTFILESIZE=250000

shopt -s histappend

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export EDITOR=vim
export PATH="$HOME/bin/sbt:$HOME/bin/texlive/2013/bin/x86_64-linux/:$PATH"

if [ -d "$HOME/.rbenv" ]; then
	export PATH="$HOME/.rbenv/bin:$PATH"
	eval "$(rbenv init -)"
fi

alias "gdb=gdb -q"
alias "briss=java -jar /home/konikos/bin/briss-0.9/briss-0.9.jar"
alias "aria2cM=aria2c -x4 -k1M"
alias 'ls=ls --group-directories-first --color=auto'
alias epfl-connect='nmcli con up id "EPFL VPN"'
alias epfl-disconnect='nmcli con down id "EPFL VPN"'
# Looooooooooooooong alias coming up!
alias clang_complete_make="make CC='~/.vim/bundle/bin/cc_args.py gcc' CXX='~/.vim/bundle/bin/cc_args.py g++' -B"
alias wget-gzip="wget --header='accept-encoding: gzip'"
alias xclip="xclip -selection c"
alias vim-update="vim +BundleInstall +qall"

apt-urls() {
	apt-get install --reinstall -qq --print-uris "$@" | cut -d ' ' -f 1 | sed "s/^'\(.*\)'$/\1/g"
}

pdf-crop() {
	for f in "$@"; do
		briss -s "$f"
	done
}

pdf-cat() {
	pdftk "$@" cat output -
	# OR:
	# gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=- "$@"
}

find-ugly() {
	find "$@" -type f -print0 \
		| xargs -0 gawk 'length() >= 80 { print FILENAME ":" FNR ":\t" $0}'
}

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

mobi2epub() {
	ls -1 "$@" | while read mobi; do
		EPUB="${mobi%.*}.epub"
		ebook-convert "$mobi" "$EPUB" --output-profile nook
	done
}

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
	local UNENCRYPTED=$(tempfile)

	if [ -f "$ENCRYPTED" ]; then
		gpg --decrypt "$ENCRYPTED" >"$UNENCRYPTED"
	else
		echo "$ENCRYPTED does not exist, it will be created.."
	fi

	vim "$UNENCRYPTED"
	gpg --encrypt --recipient 4018F537 <"$UNENCRYPTED" >"$ENCRYPTED"
	shred --force --zero --remove "$UNENCRYPTED"
}

# ssh-tunnel FROM TO MACHINE
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
	if [ $# -gt 0 ]; then
		return
	fi

	echo
	echo "Custom commands:"

	cat ~/.bash_aliases \
		| grep -o '^[^_][[:alnum:]-]*()' | grep -v '^help()$' \
		| sed -e 's/()$//' | sort \
		| while read CMD; do 
			grep "^# usage: $CMD" ~/.bash_aliases | sed -e 's/^# usage: / /'
		done
}

