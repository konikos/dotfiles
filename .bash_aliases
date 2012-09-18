alias "gdb=gdb -q"
alias "briss=java -jar /home/seth/bin/briss-0.0.13/briss-0.0.13.jar"
alias "aria2cM=aria2c -x4 -k1M"
alias 'ls=ls --group-directories-first --color=auto'
find-ugly() {
	find "$@" -type f -print0 \
		| xargs -0 gawk 'length() >= 80 { print FILENAME ":" FNR ":\t" $0}'
}
