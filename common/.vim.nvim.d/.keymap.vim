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

let g:windowswap_map_key = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>