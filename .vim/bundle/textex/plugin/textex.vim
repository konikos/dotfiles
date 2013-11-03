function! s:countWords(fname)
	return 0 + system("detex " . shellescape(a:fname) . " \| wc -w")
endfunction

function! s:countWordsSelection() range
	let lines = join(getline(getpos("'<")[1], getpos("'>")[1]), "\n")
	return 0 + system('echo ' . shellescape(lines).' | detex | wc -w')
endfunction

function! textex#echoWordsCount() range
	let msg = 'Words: ' . s:countWords(bufname('%'))
	if a:firstline != a:lastline
		let msg = msg . ' Selection: ' . s:countWordsSelection()
	endif
	echo msg
endfunction
