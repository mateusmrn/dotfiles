require "nvchad.autocmds"

-- nvim-treesitter's `master` branch (which NvChad still depends on) is
-- incompatible with Neovim 0.12+ for markdown fenced code blocks, crashing
-- the highlighter (https://github.com/nvim-treesitter/nvim-treesitter/issues/8618).
-- Stop treesitter on markdown buffers (incl. LSP hover/signature floats) until
-- NvChad migrates to the `main` branch.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.treesitter.stop()
  end,
})

-- Belt-and-suspenders for the same #8618 bug: `vim.lsp.util.open_floating_preview`
-- (used for hover/signature-help/completion-docs floats) force-restarts treesitter
-- right after setting filetype=markdown, bypassing the stop() above. The crash
-- itself happens inside nvim-treesitter's markdown injection directives, which
-- call `get_node_text` on a node missing its `range` method. Make that call
-- defensive so a bad node degrades to empty text instead of erroring out of the
-- treesitter highlighter's decoration provider mid-redraw.
local get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  local ok, result = pcall(get_node_text, node, source, opts)
  if ok then
    return result
  end
  return ""
end
