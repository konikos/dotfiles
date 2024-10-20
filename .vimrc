" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

set nocompatible              " be iMproved
filetype off                  " required!


" vim-plug and plugins {{{

if has('nvim')
	call plug#begin('~/.local/share/nvim/plugged')
else
	call plug#begin('~/.vim/plugged')
endif

Plug 'scrooloose/syntastic', { 'for': ['sh'] }

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" HTML related plugins {{{
	" omnicomplete, indent, syntax
	Plug 'othree/html5.vim'

	" fast elements creation
	Plug 'rstacruz/sparkup', { 'for': ['html', 'htmldjango'], 'rtp': 'vim/' }
" }}}

" Javascript related plugins {{{
	Plug 'pangloss/vim-javascript', { 'for': ['javascript'] }

	Plug 'MaxMEllon/vim-jsx-pretty', { 'for': ['javascript'] }
" }}}

Plug 'derekwyatt/vim-scala'

Plug 'Shirk/vim-gas'

Plug 'fatih/molokai'
Plug 'Reewr/vim-monokai-phoenix'

Plug 'tpope/vim-fugitive'

Plug 'rust-lang/rust.vim', { 'for': ['rust'] }

Plug 'cakebaker/scss-syntax.vim', { 'for': ['scss'] }

Plug 'stephpy/vim-yaml', { 'for': ['yaml'] }

Plug 'jceb/vim-orgmode', { 'for': ['org'] }
Plug 'tpope/vim-speeddating', { 'for': ['org'] }

Plug 'motus/pig.vim', { 'for': ['pig'] }

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

if has('win32') || isdirectory('C:\Windows') || isdirectory('/c/Windows') || isdirectory('/cygdrive/c/Windows')
	Plug 'ctrlpvim/ctrlp.vim'
else
	Plug 'autozimu/LanguageClient-neovim', {
		\ 'branch': 'next',
		\ 'do': 'bash install.sh',
		\ }

	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
	Plug 'junegunn/fzf.vim'
endif

Plug 'ervandew/supertab'

Plug 'udalov/kotlin-vim'

Plug 'jiangmiao/auto-pairs'

Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

call plug#end()
" }}}

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
set backspace=indent,eol,start
set nonumber
set relativenumber
set history=1000
set shell=/bin/bash
set splitright
set hidden
" }}}


" Resize splits when the window is resized
au VimResized * exe "normal! \<c-w>="


" Tabs, spaces, wrapping {{{
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set wrap
" }}}


" Backups {{{
if has('nvim')
	set undodir=~/.local/share/nvim/tmp/undo/
	set backupdir=~/.local/share/nvim/tmp/backup/
	set directory=~/.local/share/nvim/tmp/swap/
else
	set undodir=~/.vim/tmp/undo//
	set backupdir=~/.vim/tmp/backup//
	set directory=~/.vim/tmp/swap//
endif

set backup
set backupskip=/tmp/*
" }}}


" Leader {{{
let mapleader = "\\"
let maplocalleader = ","
" }}}


" Colorscheme {{{
if has("syntax")
	syntax on

	colorscheme desert

	if &term =~ "^xterm" || &term =~ "^screen" || &term =~ "^tmux" || has("gui_running") || has('nvim')
		if ! has("gui_running")
			set t_Co=256
		endif

		set background=dark
		let g:rehash256 = 1
		colorscheme monokai-phoenix
		highlight Comment cterm=NONE
		set cursorline
	endif
endi
" }}}


" Search {{{
set incsearch
set showmatch
set hlsearch

" Toggle search highlighting
noremap <leader><space> :nohlsearch<CR>

" Display all lines with keyword under cursor and ask to which one to jump
nmap <leader>/ [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" Go to the next conflict marker
map <leader>gc /\v^[<\|=>]{7}( .*\|$)<CR>
" }}}


" Wildmenu completion {{{
set wildmenu
set wildmode=list:longest,full

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


" Make D and Y behave by working to the end of the line {{{
nnoremap D d$
nnoremap Y y$
" }}}


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

" Jump to the last position when reopening a file
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
" }}}


" (Try to) capture F1 key strokes
inoremap <F1> <ESC>


" Remove space characters from the end of the lines
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>


" Copy/paste from the system clipboard
nnoremap <leader>p "+p
nnoremap <leader>y "+y
vnoremap <leader>y "+y


" Don't exit Visual Mode on shifting {{{
vnoremap < <gv
vnoremap > >gv
" }}}


" Moving between buffers {{{
nnoremap <leader><leader> :bn!<CR>
nnoremap <leader><BS> :bp!<CR>
nnoremap <leader>l :ls<CR>
" }}}


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
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" }}}


" Replace under cursor {{{
nnoremap <leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
" Prefilled replace-with text
nnoremap <leader>S :%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
" }}}


" Make shortcuts {{{
nnoremap <leader>ff :make<cr>
nnoremap <leader>fc :make clean<cr>
" }}}


" Move lines up or down {{{
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
" }}}


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


" Statusline {{{
set laststatus=2

set statusline=%<%f\                     " Filename
set statusline+=%w%h%m%r                 " Options
set statusline+=%{fugitive#statusline()} " Git Awesomeness
set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
" }}}


" Change current working dir to the current file's dir
cmap cd. lcd %:p:h


" Execute '.' once for each line of a visual selection
" http://stackoverflow.com/a/8064607
vnoremap . :normal .<CR>


" Shortcuts to quickly open files in the directory of the current file {{{

" Expands `%%` to the directory of the current file anywhere in the command
" line
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

" Edit in new window
map <leader>ew :e %%
" Edit in split
map <leader>es :sp %%
" Edit in vsplit
map <leader>ev :vsp %%
" }}}

" Quickfix Navigation {{{
nnoremap <leader>cc :cc<CR>
nnoremap <leader>cw :cw<CR>
" }}}

" sudo write file
cmap w!!! w !sudo tee % >/dev/null


" Autocompletion {{{
set completeopt=menu,menuone
" }}}


" SuperTab {{{
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestHighlight = 1
" }}}


" NERDTree {{{
nnoremap <leader>t :NERDTree<CR>
let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$', '^__pycache__$']
" }}}


" fzf {{{
" Setup the fzf default source command (find) to ignore some files.
let s:fzf_ignore_files = [
		\ '\*.swp', '\*.swo', '\*~',
		\ '.gitignore',
		\ '\*.pyc', '\*.pyd', '.coverage' ]

let s:fzf_ignore_dirs = [
		\ '.cache',
		\ '.git', '.hg', '.svn', 'CVS', '.bzr',
		\ '__pycache__', 'site-packages', '\*egg-info', '.tox',
		\ 'node_modules',
		\ 'CMakeFiles',
		\ 'tmp', '.idea' ]

let $FZF_DEFAULT_COMMAND =
		\ 'find'
		\ . ' \( \( -iname ' . join(s:fzf_ignore_dirs, ' -o -iname ')  . ' \) -a -type d \) -prune -o'
		\ . ' \( -iname ' . join(s:fzf_ignore_files, ' -o -iname ')  . ' \) -prune -o'
		\ . ' -type f -print'

nnoremap <silent> <C-P> :Buffers<CR>
nnoremap <silent> <leader>ee :Files<CR>
nnoremap <silent> <leader>ag :execute 'Ag ' . input('Ag/')<CR>

function! SearchWordWithAg()
	execute 'Ag' expand('<cword>')
endfunction

function! SearchVisualSelectionWithAg() range
	let old_reg = getreg('"')
	let old_regtype = getregtype('"')
	let old_clipboard = &clipboard
	set clipboard&
	normal! ""gvy
	let selection = getreg('"')
	call setreg('"', old_reg, old_regtype)
	let &clipboard = old_clipboard
	execute 'Ag' selection
endfunction

nnoremap <silent> K :call SearchWordWithAg()<CR>
vnoremap <silent> K :call SearchVisualSelectionWithAg()<CR>
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

	augroup ft_javscript
		au!
		au FileType javascript setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
	augroup END

	augroup ft_bash
		au!
		au BufRead,BufNewFile .bash_* let b:is_bash=1
		au BufRead,BufNewFile .bash_* set filetype=sh
	augroup END

	augroup ft_typescript
		au!
		au FileType typescript setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
		au FileType typescript.tsx setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
		au FileType typescript match ErrorMsg '\%>99v.\+'
		au FileType typescript.tsx match ErrorMsg '\%>99v.\+'
	augroup END

	augroup ft_css
		au!
		au FileType css setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
	augroup END
endif
" }}}

" Enable mouse support {{{
if has("mouse")
	set mouse=a
endif
" }}}

" LanguageClient-neovim configuration {{{
let g:LanguageClient_serverCommands = {}

" Configure LanguageClient for Go
if executable($GOBIN . '/gopls')
	let g:LanguageClient_serverCommands['go'] = [$GOBIN . '/gopls']
endif

for path in ['./tmp/venv/bin/pyls', 'pyls']
	if executable(path)
		let g:LanguageClient_serverCommands['python'] = [path]
		break
	endif
endfor

nnoremap <F5> :call LanguageClient_contextMenu()<CR>

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <leader>rr :call LanguageClient#textDocument_rename()<CR>

" }}}
