" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'VundleVim/Vundle.vim'           " let Vundle manage Vundle, required
Plugin 'rking/ag.vim'                   " ag search
Plugin 'ervandew/supertab'              " Tab completion
Plugin 'klen/python-mode'               " Python code checking plugin
Plugin 'phleet/vim-mercenary'           " Mercurial plugin
Plugin 'tpope/vim-fugitive'             " Git plugin
Plugin 'fisadev/vim-isort'              " Python import sorting
Plugin 'Chiel92/vim-autoformat'         " Auto-format
Plugin 'bling/vim-airline'              " Status bar mods
Plugin 'thirtythreeforty/lessspace.vim' " Remove eol whitespace
Plugin 'wesQ3/vim-windowswap'           " Yank/paste splits

call vundle#end()            " required

" Source common nvim/vim settings
source $HOME/.common.vim
