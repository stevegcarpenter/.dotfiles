let g:pluginpath='~/.vim/plugged'              " Set plugin manager path

if empty(glob('~/.vim/autoload/plug.vim'))
  silent call system('mkdir -p ~/.vim/{autoload,plugged,undo,backup,swp}')
  silent call system('curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
  execute 'source ~/.vim/autoload/plug.vim'
  augroup plugsetup
    autocmd!
    autocmd VimEnter * PlugInstall
  augroup end
endif

source ~/.vim.nvim.d/.vim.nvim.rc              " Source all rc files
