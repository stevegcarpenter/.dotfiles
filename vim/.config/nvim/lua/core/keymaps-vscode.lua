-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- clear search highlights
keymap.set("n", "<C-n>", ":nohl<CR>")

-- comment line in vscode
keymap.set({'x', 'n', 'o'}, 'gc', '<Plug>VSCodeCommentary')
keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

-- Write/Quit
keymap.set('n', '<leader>w', '<Cmd>Write<CR>')
keymap.set('n', '<leader>q', '<Cmd>Xit<CR>')

-- Capital JK move code lines/blocks up & down (only in visual mode)
keymap.set('x', 'J', [[:move '>+1<CR>gv=gv]])
keymap.set('x', 'K', [[:move '<-2<CR>gv=gv]])

-- Visual indentation goes back to same selection
keymap.set('x', '<', '<gv')
keymap.set('x', '>', '>gv')