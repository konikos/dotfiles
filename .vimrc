" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" set nocompatible

call pathogen#runtime_append_all_bundles() 

set ts=4 sts=4 sw=4 noexpandtab

if has("syntax")
	syntax on
endif

colorscheme desert
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
if has("autocmd")
	filetype plugin indent on

	" Override defaults
	autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab
	autocmd FileType c setlocal ts=4 sts=4 sw=4 noexpandtab
	autocmd FileType php setlocal ts=4 sts=4 sw=4 noexpandtab
	autocmd FileType make setlocal ts=4 sts=4 sw=4 noexpandtab

endif

"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
"set mouse=-a		" Enable mouse usage (all modes)

" Highlight lines longer than 80 characters
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

inoremap <F1> <ESC>
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>
nnoremap <leader>v V`]
nnoremap <leader>w <C-w>v<C-w>l

set hidden
