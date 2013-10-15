HISTFILESIZE=250000

shopt -s histappend

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export EDITOR=vim
export PATH="/home/konikos/bin/sbt/bin:$PATH"

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

# usage: v [VENV_DIR=tmp/venv]
v() {
	local VD="$1"
	[ -z "$VD" ] && VD=tmp/venv
	. "$VD/bin/activate"
}

# usage: vt TMP_VENV
# TODO: move to v -t VENV
vt() {
	local VD=~/"tmp/venv/$1"
	if [ ! -d "$VD" ]; then
		echo "venv directory does not exist: $VD" 1>&2
		return 1
	fi
	v "$VD"
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
