set nocompatible              " be iMproved, required

filetype plugin indent on     " required
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype c    setlocal ts=4 sw=4 expandtab
autocmd Filetype cpp  setlocal ts=4 sw=4 expandtab
autocmd Filetype sdl  setlocal ts=4 sw=4 expandtab

set encoding=utf-8
scriptencoding utf-8

" undo files
if isdirectory($HOME . '/.vim/.undo') == 0
    :silent !mkdir -p ~/.vim/.undo >/dev/null 2>&1
endif
set undodir=~/.vim/.undo//

" backup files
if isdirectory($HOME . '/.vim/.backup') == 0
    :silent !mkdir -p ~/.vim/.backup >/dev/null 2>&1
endif
set backupdir=~/.vim/.backup//

" swap files
if isdirectory($HOME . '/.vim/.swp') == 0
    :silent !mkdir -p ~/.vim/.swp >/dev/null 2>&1
endif
set directory=~/.vim/.swp//

" enable displaying line no along with relative numbers
set number
set relativenumber

""""""" SuperTab configuration """""""
"let g:SuperTabDefaultCompletionType = "<c-x><c-u>"
function! Completefunc(findstart, base)
    return "\<c-x>\<c-p>"
endfunction

" Key Mappings
"-----------------------------------------------------------------------------
" Set the leader keys
let mapleader="\ "

" easier way to exit insert mode
inoremap JJ <esc>
inoremap jj <esc>

" split window fast
nnoremap <leader>\| :vsplit<CR>
nnoremap <leader>- :split<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>o :edit<Space>
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" exit hlmode
nnoremap <C-n> :nohl<CR>
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

" Settings
"-----------------------------------------------------------------------------
" fix coloring in urxvt
let base16colorspace=256

" enabled syntax highlighting

" turn off folding in python-mode
let g:pymode_folding = 0
" only allow auto-complete (default will enable docs preview also)¬
" set completeopt=
let g:pymode_rope=0

" configure sorting of imports
let g:vim_isort_python_version = 'python3'
" turn off folding in python-mode

syntax on        " enable syntax highlighting
set background=dark
set hidden       " allow switching to new buffer w/o saving changes
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoindent
set list
set listchars=eol:¬,tab:¶_,extends:>,precedes:<
set ruler        " display cursor position in status line
set laststatus=2 " always display status line
set scrolloff=5  " scroll when cursor is 5 lines from top/bottom
set textwidth=78
set wrapmargin=0
set colorcolumn=+1
highlight ColorColumn ctermbg=DarkRed
set confirm      " ask to save when exiting unsaved files
set noshowmode   " disable mode status since airline does this
set splitright   " More natural splits

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
