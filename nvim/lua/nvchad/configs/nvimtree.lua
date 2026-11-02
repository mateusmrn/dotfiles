dofile(vim.g.base46_cache .. "nvimtree")

local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  api.config.mappings.default_on_attach(bufnr)

  -- make "l" behave like Enter (open file / expand folder)
  vim.keymap.set("n", "l", api.node.open.edit, {
    desc = "nvim-tree: open",
    buffer = bufnr,
    noremap = true,
    silent = true,
    nowait = true,
  })
end

return {
  on_attach = on_attach,
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    side = "right",
    preserve_window_proportions = true,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}
