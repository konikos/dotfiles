setlocal errorformat=%f:%l:\ %m,%f:%l-%\\d%\\+:\ %m
if filereadable('Makefile')
	setlocal makeprg=make
else
	exec "setlocal makeprg=rubber\\ -f\\ --pdf\\ -s\\ " . bufname("%") . ";\\ rubber-info\\ --check\\ " . bufname("%")
endif
