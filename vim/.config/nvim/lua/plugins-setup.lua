-- auto install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- add list of plugins to install
require("lazy").setup({
  "nvim-lua/plenary.nvim", -- lua functions that many plugins use

  "bluz71/vim-nightfly-colors", -- preferred colorscheme

  "christoomey/vim-tmux-navigator", -- tmux & split window navigation

  "szw/vim-maximizer", -- maximizes and restores current window

  -- essential plugins
  "tpope/vim-surround", -- add, delete, change surroundings (it's awesome)
  "inkarkat/vim-ReplaceWithRegister", -- replace with register contents using motion (gr + motion)

  -- commenting with gc
  "numToStr/Comment.nvim",

  -- file explorer
  "nvim-tree/nvim-tree.lua",

  -- vs-code like icons
  "nvim-tree/nvim-web-devicons",

  -- statusline
  "nvim-lualine/lualine.nvim",

  -- fuzzy finding w/ telescope
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- dependency for better sorting performance
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, -- fuzzy finder

  -- autocompletion
  "hrsh7th/nvim-cmp", -- completion plugin
  "hrsh7th/cmp-buffer", -- source for text in buffer
  "hrsh7th/cmp-path", -- source for file system paths

  -- snippets
  "L3MON4D3/LuaSnip", -- snippet engine
  "saadparwaiz1/cmp_luasnip", -- for autocompletion
  "rafamadriz/friendly-snippets", -- useful snippets

  -- managing & installing lsp servers, linters & formatters
  "mason-org/mason.nvim", -- in charge of managing lsp servers, linters & formatters
  "mason-org/mason-lspconfig.nvim", -- bridges gap b/w mason & lspconfig

  -- configuring lsp servers
  "neovim/nvim-lspconfig", -- easily configure language servers
  "hrsh7th/cmp-nvim-lsp", -- for autocompletion
  "nvimdev/lspsaga.nvim", -- enhanced lsp uis
  "onsails/lspkind.nvim", -- vs-code like icons for autocompletion

  -- formatting & linting
  "nvimtools/none-ls.nvim", -- configure formatters & linters (maintained fork of null-ls)
  "nvimtools/none-ls-extras.nvim", -- extra sources removed from none-ls core (eslint_d)
  "jay-babu/mason-null-ls.nvim", -- bridges gap b/w mason & null-ls

  -- treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
  },

  -- auto closing
  "windwp/nvim-autopairs", -- autoclose parens, brackets, quotes, etc...
  "windwp/nvim-ts-autotag", -- autoclose tags

  -- git integration
  "lewis6991/gitsigns.nvim", -- show line modifications on left hand side
}, {
  install = { colorscheme = { "nightfly" } },
  change_detection = { notify = false },
})
