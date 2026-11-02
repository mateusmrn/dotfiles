-- Custom theme matching the system-wide palette (wallpaper-derived,
-- shared with the Quickshell statusbar and Alacritty's color scheme).

local M = {}

M.base_30 = {
  white = "#eaf4fa",
  darker_black = "#0a1f2e",
  black = "#11293c", -- nvim bg (matches Alacritty's background)
  black2 = "#16324a",
  one_bg = "#11293c", -- real bg
  one_bg2 = "#16324a",
  one_bg3 = "#16324a",
  grey = "#16324a",
  grey_fg = "#6f93a8",
  grey_fg2 = "#6f93a8",
  light_grey = "#6f93a8",
  red = "#ff5a5f",
  baby_pink = "#d1a6ec",
  pink = "#b983e0",
  line = "#16324a", -- for lines like vertsplit
  green = "#4ddba0",
  vibrant_green = "#6de8bc",
  nord_blue = "#0098e3",
  blue = "#19b6ee",
  yellow = "#ffd23f",
  sun = "#ffdc6b",
  purple = "#d1a6ec",
  dark_purple = "#b983e0",
  teal = "#5ec1eb",
  orange = "#ff7b7f",
  cyan = "#5ec1eb",
  statusline_bg = "#11293c",
  lightbg = "#16324a",
  pmenu_bg = "#19b6ee",
  folder_bg = "#19b6ee",
}

M.base_16 = {
  base00 = "#11293c",
  base01 = "#16324a",
  base02 = "#16324a",
  base03 = "#6f93a8",
  base04 = "#6f93a8",
  base05 = "#eaf4fa",
  base06 = "#eaf4fa",
  base07 = "#eaf4fa",
  base08 = "#ff5a5f",
  base09 = "#ffd23f",
  base0A = "#ffdc6b",
  base0B = "#4ddba0",
  base0C = "#5ec1eb",
  base0D = "#19b6ee",
  base0E = "#b983e0",
  base0F = "#ff7b7f",
}

M.type = "dark"

M = require("base46").override_theme(M, "oceanic")

return M
