-- import glow plugin safely
local setup, glow = pcall(require, "glow")
if not setup then
  return
end

-- configure glow
glow.setup({
  glow_path = vim.fn.exepath("glow"), -- use the brew-installed binary
  border = "rounded",
  style = "dark",
  width_ratio = 0.8, -- floating window width as % of editor width
  height_ratio = 0.8, -- floating window height as % of editor height
})
