require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-d>", "<cmd> NvimTreeToggle <cr>", { desc = "Toggle file tree" })

map("n", "<leader>tb", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle git blame for current line" })

map("n", "]d", function()
  vim.diagnostic.jump { count = 1 }
end, { desc = "Next diagnostic" })

map("n", "[d", function()
  vim.diagnostic.jump { count = -1 }
end, { desc = "Previous diagnostic" })

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
