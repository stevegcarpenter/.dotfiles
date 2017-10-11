" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

Plug 'rking/ag.vim'                   " ag search
Plug 'phleet/vim-mercenary'           " Mercurial plugin
Plug 'ervandew/supertab'              " Tab completion
Plug 'python-mode/python-mode'        " Python code checking plugin
Plug 'bling/vim-airline'              " Status bar mods
Plug 'thirtythreeforty/lessspace.vim' " Remove eol whitespace
Plug 'wesQ3/vim-windowswap'           " Yank/paste splits
Plug 'fisadev/vim-isort'              " Python import sorting

call plug#end()

" Source common nvim/vim settings
source $HOME/.common.vim
