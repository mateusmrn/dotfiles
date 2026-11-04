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

-- volume controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- screenshots
-- region select, then annotate/crop/blur before saving or copying
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
hl.bind("SUPER + P",     hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))
-- full screen, straight to clipboard
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SHIFT + SUPER + P",    hl.dsp.exec_cmd("grim - | wl-copy"))

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

-- cycle through active (non-empty) workspaces, wrapping around
hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + N",           hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + N",   hl.dsp.focus({ workspace = "e-1" }))

-- toggle maximize (fills the workspace, app isn't told it's fullscreen)
hl.bind("SUPER + F", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 1, client = 0 }))

-- toggle real fullscreen for current window
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())

-- toggle floating for current window
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

-- drag/resize floating windows with the mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Anki always opens floating
hl.window_rule({ match = { class = "Anki" }, float = true })

-- distinct border while maximized (SUPER + F): it otherwise looks identical
-- to a large tiled window, so this makes the state visible on the window itself
hl.window_rule({
    name  = "maximize-border",
    match = { fullscreen_state_internal = 1 },
    border_color = "rgba(f5a623ee)",
})

-- screen recording (toggle: press again to stop and finalize)
local recordScript = "/home/mateus/dotfiles/hypr/scripts/toggle-recording.sh"
hl.bind("SUPER + R",         hl.dsp.exec_cmd(recordScript .. " region"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(recordScript .. " full"))

-- resize mode submap (disabled for now: SUPER + R repurposed for screen recording)
-- hl.bind("SUPER + R", hl.dsp.submap("resize"))
-- hl.define_submap("resize", function()
--     hl.bind("l", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
--     hl.bind("j", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })
--     hl.bind("k", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
--     hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
--     hl.bind("escape", hl.dsp.submap("reset"))
-- end)

-- dock mode submap: focus/launch/cycle pinned apps by number
local dockScript = "/home/mateus/dotfiles/hypr/scripts/dock-app.sh"
local dockApps = {
    { key = "1", class = "Alacritty",            exec = terminal },
    { key = "2", class = "firefox",              exec = "firefox" },
    { key = "3", class = "Code",                 exec = "code" },
    { key = "4", class = "Spotify",              exec = "spotify" },
    { key = "5", class = "md.obsidian.Obsidian", exec = "obsidian" },
}

hl.bind("SUPER + D", hl.dsp.submap("dock"))
hl.define_submap("dock", function()
    for _, app in ipairs(dockApps) do
        hl.bind(app.key, hl.dsp.exec_cmd(dockScript .. " '" .. app.class .. "' '" .. app.exec .. "'"))
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- layout mode submap: switch the active layout by number
local layouts = {
    { key = "1", name = "dwindle" },
    { key = "2", name = "master" },
}

hl.bind("SUPER + M", hl.dsp.submap("layout"))
hl.define_submap("layout", function()
    for _, l in ipairs(layouts) do
        hl.bind(l.key, hl.dsp.exec_cmd("hyprctl keyword general:layout " .. l.name))
    end
    hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.config({
    general = {
        col = {
            -- active: full-strength cyan accent; inactive: statusbar's subtle border
            active_border = "rgba(19b6eee6)",
            inactive_border = "rgba(5ec1eb29)",
        },
    },
    input = {
        -- US and US international (dead-key accents) layouts
        kb_layout = "us,us(intl)",
        -- map caps lock to ESC; toggle keyboard layout with ALT + SHIFT
        kb_options = "caps:escape,grp:alt_shift_toggle",
        -- how fast a held down key is repeated
        repeat_rate = 40,
        -- how long in ms it takes for it to start repeating
        repeat_delay = 200,
    },
    decoration = {
        rounding = 20,
        blur = {
            enabled = true,
            size = 4,
            passes = 2,
        },
    },
})
