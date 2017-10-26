let g:pluginpath='~/.local/share/nvim/plugged'   " Set plugin manager path

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent call system('mkdir -p ~/.local/share/nvim/site/autoload/')
  silent call system('curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
  augroup plugsetup
    autocmd!
    autocmd VimEnter * PlugInstall
  augroup end
endif

source ~/.vim.nvim.d/.vim.nvim.rc                " Source all rc files
