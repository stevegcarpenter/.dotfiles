-- only use these settings when not in vscode
if vim.g.vscode then
  require("core.options")
  require("core.keymaps-vscode")
else
  require("core.options")
  require("core.keymaps") -- sets mapleader, which must happen before lazy.nvim loads
  require("plugins-setup")
  require("core.colorscheme")
  require("plugins.comment")
  require("plugins.nvim-tree")
  require("plugins.lualine")
  require("plugins.telescope")
  require("plugins.nvim-cmp")
  require("plugins.lsp.mason")
  require("plugins.lsp.lspsaga")
  require("plugins.lsp.lspconfig")
  require("plugins.lsp.null-ls")
  require("plugins.autopairs")
  require("plugins.treesitter")
  require("plugins.gitsigns")
end
