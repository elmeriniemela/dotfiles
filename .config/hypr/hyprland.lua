-- A separate Wayland session; Awesome and its X11 startup remain independent.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")

-- Keep any external display above the built-in panel, regardless of connection order.
hl.monitor({ output = "", mode = "preferred", position = "auto-center-up", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto-center-down", scale = 1 })

hl.config({
    input = { kb_layout = "fi", touchpad = { natural_scroll = true } },
    general = { gaps_in = 5, gaps_out = 10, border_size = 2, layout = "dwindle" },
    decoration = { rounding = 8 },
    animations = { enabled = false },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell -p ~/.config/hypr/quickshell --no-duplicate")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
end)

hl.bind("SUPER + K", hl.dsp.exec_cmd("python3 ~/.config/hypr/keybindings.py"), { description = "Show keyboard shortcuts" })
hl.bind("SUPER + V", hl.dsp.exec_cmd("python3 ~/.config/hypr/clipboard.py"), { description = "Open clipboard history" })

hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"), { description = "Open terminal" })
hl.bind("ALT + Return", hl.dsp.exec_cmd("alacritty"), { description = "Open terminal" })
hl.bind("SUPER + space", hl.dsp.exec_cmd("rofi -show drun"), { description = "Open app launcher" })
-- Cycle across regular workspaces; keep hidden scratchpad windows out of the list.
local function cycle_window(step)
    local windows = {}
    for _, window in ipairs(hl.get_windows()) do
        if not window.hidden and window.workspace and not window.workspace.name:match("^special:") then
            table.insert(windows, window)
        end
    end
    if #windows == 0 then return end

    local active = hl.get_active_window()
    local index = step > 0 and 1 or #windows
    for i, window in ipairs(windows) do
        if active and window.address == active.address then
            index = (i - 1 + step) % #windows + 1
            break
        end
    end
    hl.dispatch(hl.dsp.focus({ window = windows[index] }))
end

hl.bind("ALT + Tab", function() cycle_window(1) end, { description = "Focus next window across workspaces" })
hl.bind("ALT + SHIFT + Tab", function() cycle_window(-1) end, { description = "Focus previous window across workspaces" })
hl.bind("SUPER + U", function()
    local window = hl.get_urgent_window()
    if window then hl.dispatch(hl.dsp.focus({ window = window })) end
end, { description = "Focus urgent window" })
hl.bind("SUPER + Q", hl.dsp.exec_cmd("brave"), { description = "Open browser" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"), { description = "Open file manager" })
hl.bind("SUPER + C", hl.dsp.exec_cmd("codium"), { description = "Open code editor" })
hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock session" })
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("archlinux-logout"), { description = "Open logout menu" })
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("xfce4-taskmanager"), { description = "Open task manager" })

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "Focus window left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "Focus window right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "Focus window up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "Focus window down" })

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { description = "Move window right" })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })

hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true, description = "Resize window left" })
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true, description = "Resize window right" })
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true, description = "Resize window up" })
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true, description = "Resize window down" })

for workspace = 1, 9 do
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }), { description = "Switch to workspace " .. workspace })
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = false }), { description = "Send window to workspace " .. workspace })
    hl.bind("SUPER + CTRL + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }), { description = "Move window to workspace and follow " .. workspace })
end

hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }), { description = "Previous workspace" })
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Show or hide scratchpad" })
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }), { description = "Send window to scratchpad" })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window (hold and drag)" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window (hold and drag)" })

hl.bind("Print", function()
    local monitor = hl.get_active_monitor()
    hl.exec_cmd("env QT_QPA_PLATFORM=wayland flameshot screen --number " .. (monitor and monitor.id or 0) .. " --edit")
end, { description = "Take screenshot of active monitor with Flameshot" })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("sh ~/.config/hypr/screen-record.sh"), { description = "Start or stop region screen recording" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "Toggle sound mute" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "Toggle microphone mute" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 1%+"), { repeating = true, description = "Raise brightness" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 1%-"), { repeating = true, description = "Lower brightness" })
