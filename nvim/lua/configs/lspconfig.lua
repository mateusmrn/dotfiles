require("nvchad.configs.lspconfig").defaults()

-- ruff handles linting/fixes; defer hover to pyright to avoid duplicate popups
vim.lsp.config("ruff", {
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
})

local servers = { "html", "cssls", "pyright", "ruff" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
