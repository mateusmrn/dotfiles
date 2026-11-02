require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-d>", "<cmd> NvimTreeToggle <cr>", { desc = "Toggle file tree" })

map("n", "<leader>rc", "<cmd> source $MYVIMRC <cr>", { desc = "Reload config" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
