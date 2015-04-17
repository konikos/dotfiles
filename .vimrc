" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

set nocompatible              " be iMproved
filetype off                  " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

Bundle 'ervandew/supertab'
Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'
Bundle 'terryma/vim-multiple-cursors'
Bundle 'scrooloose/nerdtree'
Bundle 'sjl/gundo.vim'
Bundle 'Rip-Rip/clang_complete'
Bundle 'othree/html5.vim'
Bundle 'groenewege/vim-less'
Bundle 'tristen/vim-sparkup'
Bundle 'derekwyatt/vim-scala'

filetype plugin indent on     " required!

" Super extra cool matching awesomeness for html tags and more {{{
runtime! macros/matchit.vim
let b:match_debug=1 " Required otherwise matchit macros mess up paren matching.
" }}}

" Core VIM options {{{
set encoding=utf-8
set modelines=0
set autoindent
set showmode
set showcmd
"set visualbell
set backspace=indent,eol,start
set nonumber
set relativenumber
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
set hidden " loads a buffer in a window that has an unmodified buffer
" }}}


" Wildmenu completion {{{
set wildmenu
set wildmode=list:longest

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.mp4,*.mkv,*.flv,*.avi,*.mov,*.wmv,*.webm,*.vob
set wildignore+=*.luac                           " Lua byte code
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store?                      " OSX bullshit
" }}}


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
set backupskip=/tmp/*
" }}}


" Leader {{{
let mapleader = "\\"
"let maplocalleader = ","
" }}}


" Colorscheme {{{
if has("syntax")
	syntax on

	colorscheme desert

	if &term == "xterm" || &term == "screen-bce" || has("gui_running")
		set background=light
		set t_Co=256
	
		let g:molokai_original=1
		colorscheme molokai
		set cursorline
	endif
endi
" }}}


" Search options {{{
" Sane regexes
" nnoremap / /\v TODO
" vnoremap / /\v TODO

set incsearch
set showmatch
set hlsearch

noremap <leader><space> :noh<cr>:call clearmatches()<cr>
" }}}


"set scrolloff=3 TODO
"set sidescroll=1 TODO
"set sidescrolloff=10 TODO

"set virtualedit+=block TODO

" Make D behave
nnoremap D d$

" Don't move on *
nnoremap * *<c-o>


" Moving around {{{
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
" }}}


" Filetype related stuff {{{
if has("autocmd")
	filetype plugin indent on

	" vala syntax support
	autocmd BufRead *.vala set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
	autocmd BufRead *.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
	au BufRead,BufNewFile *.vala setfiletype vala
	au BufRead,BufNewFile *.vapi setfiletype vala
	au BufRead,BufNewFile *.md set filetype=markdown

	augroup ft_c
		au!
		au FileType c,cpp setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
		au FileType c,cpp match ErrorMsg '\%>79v.\+'
	augroup END

	augroup ft_scala
		au!
		au FileType scala setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
	augroup END

	augroup ft_python
		au!
		au FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
		au FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
		au FileType python match ErrorMsg '\%>79v.\+'
	augroup END

	augroup ft_html
		au!
		au FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
	augroup END

	augroup ft_make
		au!
		au FileType make setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
		au FileType make setlocal listchars=tab:▸\ 
		au FileType make setlocal list
	augroup END

	augroup ft_yaml
		au!
		au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
	augroup END

	augroup ft_scala
		au!
		au FileType scala setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
	augroup END

	augroup ft_sma
		au!
		au BufRead,BufNewFile *.sma set filetype=sma
		au FileType sma runtime! syntax/c.vim
		au FileType sma set errorformat=%f(%l)\ :\ error\ %n:\ %m
		au FileType sma set makeprg=/home/konikos/bin/amxxpc\ %\ -i/home/konikos/bin/amxx/\ -o%r
	augroup END

endif
" }}}


" Autocompletion {{{
set completeopt=menu,menuone,longest
" }}}

" SuperTab {{{
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestHighlight = 1
" }}}

" clang_complete {{{
let g:clang_complete_auto = 0
let g:clang_library_path = "/usr/lib/llvm-3.5/lib/"
" }}}


" NERDTree shortcuts {{{
nnoremap <leader>t :NERDTree<CR>
let NERDTreeIgnore = ['\.pyc$', '\.o$']
" }}}

" ctrlp.vim {{{
let g:ctrlp_cmd = 'CtrlPBuffer'
" }}}


inoremap <F1> <ESC>
" Remove space characters from the end of the lines
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Copy/paste from the system clipboard
nnoremap <leader>p "+p
nnoremap <leader>y "+y
vnoremap <leader>y "+y


"nnoremap <leader>v V`] TODO

"Moving between buffers
nnoremap <leader><leader> :bn!<CR>
nnoremap <leader><BS> :bp!<CR>
nnoremap <leader>l :ls<CR>

" Window shortcuts {{{
nnoremap <leader>ww <C-w>v<C-w>l
nnoremap <leader>wm <C-w>_
nnoremap <leader>w+ <C-w>|
nnoremap <leader>w= <C-w>=
nnoremap <leader>] <C-w>w
nnoremap <leader>[ <C-w>W
nnoremap <leader>} <C-w>x<C-w>w
nnoremap <leader>{ <C-w>W<C-w>x
nnoremap <leader>w} <C-w>L
nnoremap <leader>w{ <C-w>H
" }}}


" awesome replace word under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>


"" TeX
"nnoremap <leader>tt :call textex#echoWordsCount()<cr>
"vnoremap <leader>tt :call textex#echoWordsCount()<cr>

nnoremap <leader>ff :make<cr>
nnoremap <leader>fc :make clean<cr>


" GUI specific settings {{{
if has("gui_running")
	" No menubar
	set guioptions-=T
	" No lame tearoff menus
	set guioptions-=t

	set columns=105
	set lines=55

	set guifont=Monospace\ 10
endif
" }}}

