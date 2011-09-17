" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

call pathogen#infect()


set encoding=utf-8
set modelines=0
set autoindent
set showmode
set showcmd
"set visualbell
set backspace=indent,eol,start
set nonumber
set norelativenumber
"set laststatus=2
set history=1000
"set undofile
"set undoreload=10000
set shell=/bin/bash
"set lazyredraw
"set splitbelow
set splitright
"set fillchars=diff:\ TODO TODO
"set notimeout TODO
"set nottimeout TODO
set hidden

" Wildmenu completion {{{
set wildmenu
set wildmode=list:longest

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.luac                           " Lua byte code
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store?                      " OSX bullshit
" }}}

set backupskip=/tmp/*

" Save when losing focus
"au FocusLost * :wa

" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="

" Tabs, spaces, wrapping {{{
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set wrap
"set textwidth=85
"set formatoptions=qrn1 TODO: fo-table
"set colorcolumn=+1
" }}}

" Backups {{{
set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files
set backup                        " enable backups
" }}}


" Leader {{{
let mapleader = "\\"
"let maplocalleader = ","
" }}}


if has("syntax")
	syntax on
	set background=light
	set t_Co=256

	let g:molokai_original=1
	colorscheme molokai
	set cursorline
endif

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

set incsearch
set showmatch
set hlsearch
set gdefault

"set scrolloff=3 TODO
"set sidescroll=1 TODO
"set sidescrolloff=10 TODO

"set virtualedit+=block TODO

noremap <leader><space> :noh<cr>:call clearmatches()<cr>

" Made D behave
nnoremap D d$

" Don't move on *
nnoremap * *<c-o>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

noremap j gj
noremap k gk

" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
	filetype plugin indent on

	" vala syntax support
	autocmd BufRead *.vala set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
	autocmd BufRead *.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
	au BufRead,BufNewFile *.vala            setfiletype vala
	au BufRead,BufNewFile *.vapi            setfiletype vala


	" Override defaults
	autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
	autocmd FileType c setlocal ts=4 sts=4 sw=4 noexpandtab
	autocmd FileType php setlocal ts=4 sts=4 sw=4 noexpandtab
	autocmd FileType make setlocal ts=4 sts=4 sw=4 noexpandtab

endif


inoremap <F1> <ESC>
" Remove space characters from the end of the lines
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

"nnoremap <leader>v V`] TODO

" Vertical split and switch over
nnoremap <leader>w <C-w>v<C-w>l
