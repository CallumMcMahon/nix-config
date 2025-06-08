-- VSCode-specific LSP keymaps
-- In VSCode mode, vscode-neovim automatically converts LSP calls to VSCode actions
-- See https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/keymaps.lua
-- and https://github.com/vscode-neovim/vscode-neovim/blob/master/runtime/vscode/lsp/buf.lua
if vim.g.vscode then
  vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References', nowait = true })
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
  vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
  vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
  vim.keymap.set('n', '<leader>co', vim.lsp.buf.code_action, { desc = 'Code Action' })
  
  -- setting a better default
  local vscode = require('vscode')
  -- "VSCode's jumplist is used instead of Neovim's", see vscode-neovim's README
  -- vim.keymap.set('n', 'gd', function() vscode.action('editor.action.goToDefinition') end, { desc = 'Goto Definition' })
  vim.keymap.set('n', 'gy', function() vscode.action('editor.action.goToTypeDefinition') end, { desc = 'Goto T[y]pe Definition' })
  
  -- Suppress unsupported LSP function warnings
  vim.lsp.buf.clear_references = function() end
end

return {}