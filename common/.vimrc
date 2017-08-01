set nocompatible              " be iMproved, required

" Set the leader keys
let mapleader="\ "
let maplocalleader="\\"

filetype plugin indent on     " required
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype c setlocal ts=4 sw=4 expandtab
autocmd Filetype cpp setlocal ts=4 sw=4 expandtab
autocmd Filetype sdl setlocal ts=4 sw=4 expandtab
autocmd Filetype python nnoremap <LocalLeader>= :0,$!yapf<CR>
autocmd FileType python nnoremap <LocalLeader>i :!isort %<CR><CR>

scriptencoding utf-8
set encoding=utf-8

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" EasyMotion - Allows <leader><leader>(b|e) to jump to (b)eginning or (end)
" of words.
" Plugin 'easymotion/vim-easymotion'

Plugin 'rking/ag.vim'      " ag search
Plugin 'ervandew/supertab' " Tab completion

" Agrigate of python related plugins
Plugin 'klen/python-mode' " Python code checking plugin

" import sorting plugin
Plugin 'fisadev/vim-isort'

" Edit multiple lines simultaneously
" Plugin 'terryma/vim-multiple-cursors' " Multiple cursors

" formatting
Plugin 'Chiel92/vim-autoformat'

" Status bar mods
Plugin 'bling/vim-airline'

" Remove extraneous whitespace when edit mode is exited
" Plugin 'thirtythreeforty/lessspace.vim'

" Cleverly yank and paste splits
Plugin 'wesQ3/vim-windowswap'

" All of your Plugins must be added before the following line
call vundle#end()            " required

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set backup
set backupdir=~/.backup,.
set noswapfile

" enable displaying line no along with relative numbers
set number
set relativenumber


""""""" SuperTab configuration """""""
"let g:SuperTabDefaultCompletionType = "<c-x><c-u>"
function! Completefunc(findstart, base)
    return "\<c-x>\<c-p>"
endfunction

"----------------------------------------------------------------------
" Key Mappings
"----------------------------------------------------------------------

" Remap a key sequence in insert mode to kick me out to normal
" mode. This makes it so this key sequence can never be typed
" again in insert mode, so it has to be unique.
inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>
inoremap kk <esc>
inoremap kK <esc>
inoremap Kk <esc>
inoremap KK <esc>
inoremap jk <esc>
inoremap jK <esc>
inoremap Jk <esc>
inoremap JK <esc>

" background darkness
set background=dark

" fix coloring in urxvt
let base16colorspace=256

" enabled syntax highlighting
syntax on

" configure sorting of imports
let g:vim_isort_python_version = 'python3'
" turn off folding in python-mode
let g:pymode_folding = 0
" only allow auto-complete (default will enable docs preview also)¬
" set completeopt=
let g:pymode_rope=0

"" allow switching to new buffer w/o saving changes
set hidden

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch
" Incrementally update search as typing
set incsearch

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

set list
set listchars=eol:¬,tab:¶_,extends:>,precedes:<

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Start scrolling when the cursor is 5 lines from the bottom/top of page
set scrolloff=5

set textwidth=78
set wrapmargin=0
set colorcolumn=+1
highlight ColorColumn ctermbg=DarkRed

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Display line numbers on the left
" set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Set statusline
set statusline=                       " clear
set statusline+=%<\                   " cut at start
set statusline+=%2*[%n%H%M%R%W]%*\    " flags and buf no
set statusline+=%-40F\                " path
set statusline+=%=%1*%y%*%*\          " file type
set statusline+=%10((%l,%c,%L)%)\     " line, column, total lines
set statusline+=%P                    " percentage of file

" tags
set tags=./tags,./TAGS,tags,TAGS,../builddxmos/tags

" Remove extraneous mode info
set noshowmode
" More natural splits
set splitright

" Visual pattern search
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch()
    let temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
    let @s = temp
endfunction

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()


let g:windowswap_map_key = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>

" split window fast
nnoremap <leader>\| :vsplit<CR>
nnoremap <leader>- :split<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>o :edit<Space>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" open buffer list, allow selection
nnoremap <leader><leader>l :buffers<CR>:buffer<Space>
" open previous file
nnoremap <leader>b :e#<CR>

" start ag search
nnoremap <leader>/ :Ag<Space>

" set/clear paste mode
nnoremap <leader>p :set paste<CR>
nnoremap <leader><leader>p :set nopaste<CR>

" save quick
nnoremap <leader>w :w<CR>
