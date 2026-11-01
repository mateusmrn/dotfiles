hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

local terminal    = "alacritty"
local fileManager = "dolphin"
local launcher    = "rofi -show drun"

-- this ghost monitor keeps appearing. disabling it.
hl.monitor({ output = "WAYLAND-1", disabled = true })

-- autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("unset HL_INITIAL_WORKSPACE_TOKEN; hyprpaper")
    hl.exec_cmd("unset HL_INITIAL_WORKSPACE_TOKEN; quickshell")
end)

-- kill current window
hl.bind("SUPER + X", hl.dsp.window.close())
-- open new terminal
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
-- open app launcher
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(launcher))

-- vim-like motion to move between windows
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))

-- move window in the specific direction
hl.bind("SUPER + ALT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + ALT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + ALT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + ALT + k", hl.dsp.window.move({ direction = "up" }))

-- go to workspace n
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
end

-- move focused window to workspace n
for i = 1, 9 do
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- cycle through workspaces
hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "-1" }))

-- toggle fullscreen for current window
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

-- resize mode submap
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("l", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
    hl.bind("j", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })
    hl.bind("k", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.config({
    input = {
        -- map caps lock to ESC
        kb_options = "caps:escape",
        -- how fast a held down key is repeated
        repeat_rate = 40,
        -- how long in ms it takes for it to start repeating
        repeat_delay = 200,
    },
    decoration = {
        rounding = 20,
    },
})
