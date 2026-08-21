-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter")
if not status then
  return
end

-- install these language parsers (no-op when they are already installed)
treesitter.install({
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "svelte",
  "graphql",
  "bash",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
})

-- enable syntax highlighting and indentation for every buffer that has a parser
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then
      return
    end
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- enable autotagging (configured separately from treesitter in newer nvim-ts-autotag)
local autotag_status, autotag = pcall(require, "nvim-ts-autotag")
if autotag_status then
  autotag.setup()
end
