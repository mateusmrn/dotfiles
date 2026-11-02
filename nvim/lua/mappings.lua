require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-d>", "<cmd> NvimTreeToggle <cr>", { desc = "Toggle file tree" })

map("n", "<leader>tb", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle git blame for current line" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
