" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - For Vim:    ~/.vim/plugged
call plug#begin(g:pluginpath)

Plug 'rking/ag.vim'                   " ag search
Plug 'Chiel92/vim-autoformat'         " Auto-format code
Plug 'phleet/vim-mercenary'           " Mercurial plugin
Plug 'tpope/vim-fugitive'             " Git plugin
Plug 'tpope/vim-surround'             " Assist in editing/adding surrounds
Plug 'ervandew/supertab'              " Tab completion
Plug 'python-mode/python-mode'        " Python code checking plugin
Plug 'bling/vim-airline'              " Status bar mods
Plug 'thirtythreeforty/lessspace.vim' " Remove eol whitespace
Plug 'wesQ3/vim-windowswap'           " Yank/paste splits
Plug 'fisadev/vim-isort'              " Python import sorting

call plug#end()
