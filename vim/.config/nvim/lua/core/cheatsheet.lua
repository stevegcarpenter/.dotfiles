-- :Cheatsheet [name] -- render a dotfiles cheat sheet in a glow float
local docs_dir = vim.fn.expand("~/.dotfiles/docs")
local default_doc = "nvim"

-- names of every "<name>-cheatsheet.md" living in the docs dir
local function doc_names()
  local names = {}
  for _, path in ipairs(vim.fn.glob(docs_dir .. "/*-cheatsheet.md", false, true)) do
    table.insert(names, (vim.fn.fnamemodify(path, ":t:r"):gsub("%-cheatsheet$", "")))
  end
  return names
end

local function open(name)
  name = (name == nil or name == "") and default_doc or name
  local path = docs_dir .. "/" .. name .. "-cheatsheet.md"
  if vim.fn.filereadable(path) == 0 then
    vim.notify("no cheat sheet at " .. path, vim.log.levels.ERROR)
    return
  end
  vim.cmd("Glow " .. vim.fn.fnameescape(path))
end

vim.api.nvim_create_user_command("Cheatsheet", function(opts)
  open(opts.args)
end, {
  nargs = "?",
  desc = "Open a dotfiles cheat sheet in a glow float",
  complete = function(lead)
    return vim.tbl_filter(function(name)
      return name:find(lead, 1, true) == 1
    end, doc_names())
  end,
})
