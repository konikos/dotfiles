#!/usr/bin/awk -f
# a simple awk script to resync srt subtitles
# it reads from stdin, writes to stdout
# run it as:
# $ awk -f subsync.awk <subtitle.srt >new_subtitle.srt
# or if it has exec permissions
# $ ./subsync.awk <subtitle.srt >new_subtitle.srt
# Don't try to write to the same file, it won't work

BEGIN {
	FS = " --> ";
	MPH = 60 * 60 * 1000;
	MPM = 60 * 1000;
	MPS = 1000;
}

function split_time(time, arr) {
	split(time, arr, /(:)|(,)/)
}

function to_milli(time) {
	return (time[1] * 60 * 60 + time[2] * 60 + time[3]) * 1000 + time[4];
}

function milli_to_str(milli) {
	h = int(milli / MPH);
	m = int((milli - h * MPH) / MPM);
	s = int((milli - h * MPH - m * MPM) / MPS);
	mil = milli - h * MPH - m * MPM - s * MPS;
	return sprintf("%.2i:%.2i:%.2i,%.3i", h, m, s, mil);
}

NF == 2 {
	split_time($1, start);
	mstart = to_milli(start);
	if (mstart >= offset)
		printf milli_to_str(mstart + delay);
	else
		printf $1;

	printf FS;

	split_time($2, end);
	mend = to_milli(end);
	if (mstart >= offset)
		printf milli_to_str(mend + delay);
	else
		printf $2;

	printf "\n";
}

NF != 2 {
	print $0;
}
