" Settings
"-----------------------------------------------------------------------------
set nocompatible              " Not comptible with Vi, always set first.
filetype plugin indent on     " required
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype c    setlocal ts=4 sw=4 expandtab
autocmd Filetype cpp  setlocal ts=4 sw=4 expandtab
autocmd Filetype sdl  setlocal ts=4 sw=4 expandtab

set encoding=utf-8
scriptencoding utf-8
" let base16colorspace=256 " Fix color in urxvt (base16-vim plugin)
syntax on                " enable syntax highlighting
set background=dark
set number               " show line numbers
set relativenumber       " display line numbers relative to cursor position
set hidden               " allow switching to new buffer w/o saving changes
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoindent
set list
set listchars=eol:¬,tab:¶_,extends:>,precedes:<
set ruler                " display cursor position in status line
set laststatus=2         " always display status line
set scrolloff=5          " scroll when cursor is 5 lines from top/bottom
set textwidth=78
set wrapmargin=0
set colorcolumn=+1
highlight ColorColumn ctermbg=DarkRed
set confirm              " ask to save when exiting unsaved files
set noshowmode           " disable mode status since airline does this
set splitright           " More natural splits

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
