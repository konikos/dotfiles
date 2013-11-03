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

	colorscheme desert

	if &term == "xterm" || &term == "screen-bce" || has("gui_running")
		set background=light
		set t_Co=256
	
		let g:molokai_original=1
		colorscheme molokai
		set cursorline
	endif
endi

" Use sane regexes.
nnoremap / /\v
vnoremap / /\v

set incsearch
set showmatch
set hlsearch

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
		au FileType html setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab
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
endif

" Autocompletion {{{
set completeopt=menu,menuone,longest
" }}}

" SuperTab {{{
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestHighlight = 1
" }}}

" clang_complete {{{
let g:clang_complete_auto = 0
let g:clang_library_path = "/usr/lib/"
" }}}

inoremap <F1> <ESC>
" Remove space characters from the end of the lines
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Paste from the system clipboard
nnoremap <leader>p "+p


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


" NERDTree shortcuts {{{
nnoremap <leader>t :NERDTree<CR>
let NERDTreeIgnore = ['\.pyc$', '\.o$']
" }}}


" awesome replace word under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" TeX
fu! TexCountWords(fname)
	return 0 + system("detex " . shellescape(a:fname) . " \| wc -w")
endfunction
nnoremap <leader>tt :echo "Words: " . TexCountWords(bufname('%'))<cr>

nnoremap <leader>ff :make<cr>
nnoremap <leader>fc :make clean<cr>

" GUI Settings {{{
if has("gui_running")
	" No menubar
	set guioptions-=T
	" No lame tearoff menus
	set guioptions-=t

	"if hostname() == "asgard"
	"	set lines=59
	set columns=105
	set lines=55

	set guifont=Monospace\ 11
endif
" }}}


" greek letters mapping
nnoremap α a
nnoremap Α A
nnoremap β b
nnoremap Β B
nnoremap ψ c
nnoremap Ψ C
nnoremap δ d
nnoremap Δ D
nnoremap ε e
nnoremap Ε E
nnoremap φ f
nnoremap Φ F
nnoremap γ g
nnoremap Γ G
nnoremap η h
nnoremap Η H
nnoremap ι i
nnoremap Ι I
nnoremap ξ j
nnoremap Ξ J
nnoremap κ k
nnoremap Κ K
nnoremap λ l
nnoremap Λ L
nnoremap μ m
nnoremap Μ M
nnoremap ν n
nnoremap Ν N
nnoremap ο o
nnoremap Ο O
nnoremap π p
nnoremap Π P
" nnoremap ; q
" nnoremap ; Q
nnoremap ρ r
nnoremap Ρ R
nnoremap σ s
nnoremap Σ S
nnoremap τ t
nnoremap Τ T
nnoremap θ u
nnoremap Θ U
nnoremap ω v
nnoremap Ω V
nnoremap ς w
nnoremap Σ W
nnoremap χ x
nnoremap Χ X
nnoremap υ y
nnoremap Υ Y
nnoremap ζ z
nnoremap Ζ Z
