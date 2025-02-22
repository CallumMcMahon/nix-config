-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Override LazyVim root detection to always use cwd
require("lazyvim.util").get_root = vim.loop.cwd
