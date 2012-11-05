alias "gdb=gdb -q"
alias "briss=java -jar /home/seth/bin/briss-0.0.13/briss-0.0.13.jar"
alias "aria2cM=aria2c -x4 -k1M"
alias 'ls=ls --group-directories-first --color=auto'

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
