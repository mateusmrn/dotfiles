local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    lsp_format = "never", -- only use dedicated formatters above, no LSP fallback
    timeout_ms = 500,
  },

  -- don't nag when a filetype has no formatter configured
  notify_no_formatters = false,
}

return options
