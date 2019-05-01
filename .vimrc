" https://dougblack.io/words/a-good-vimrc.html
" Editor lines and number settings
set relativenumber
set ruler
set showcmd
set cursorline
set wildmenu

" Folding settings
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=syntax
nnoremap <space> za

" Syntax settings
syntax on
colorscheme xterm16

" Plugins
call plug#begin('~/.vim/myplugins')
Plug 'OmniSharp/omnisharp-vim' ", {'for': 'cs'}
Plug 'w0rp/ale'
Plug 'PProvost/vim-ps1' ", {'for': 'ps1'}
Plug 'mattn/webapi-vim'
Plug 'Shougo/vimproc.vim'
Plug 'cd01/poshcomplete-vim'
call plug#end()

" OmniSharp Section
" This is required for OmniSharp to work.
filetype plugin on
" Sets Omnisharp server to 5 second timeout.
let g:OmniSharp_timeout = 5
" Sets ALE linter to use OmniSharp for cs files.
let g:ale_linters = {'cs': ['OmniSharp']}
" Don't assume first autocomplete option.
set completeopt=longest,menuone,preview
set previewheight=5

" Use only for debugging OmniSharp
"let g:OmniSharp_proc_debug = 1
"let g:OmniSharp_loglevel = 'debug'