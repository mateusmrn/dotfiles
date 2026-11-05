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
