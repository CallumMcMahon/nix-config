-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Override LazyVim root detection to always use cwd
require("lazyvim.util").get_root = vim.loop.cwd

local function print_plugins()
  local plugins = require("lazy").plugins()
  for _, plugin in pairs(plugins) do
    if plugin.url ~= nil then
      print(plugin.url .. "\n")
    end
  end
end
-- print_plugins()
