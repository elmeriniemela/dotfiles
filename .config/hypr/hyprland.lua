-- A separate Wayland session; Awesome and its X11 startup remain independent.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")

-- Keep any external display above the built-in panel, regardless of connection order.
hl.monitor({ output = "", mode = "preferred", position = "auto-center-up", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto-center-down", scale = 1 })

hl.config({
    input = { kb_layout = "fi" },
    general = { gaps_in = 5, gaps_out = 10, border_size = 2, layout = "dwindle" },
    decoration = { rounding = 8 },
    animations = { enabled = false },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
end)

hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind("ALT + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + Q", hl.dsp.exec_cmd("brave"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("codium"))
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("xfce4-taskmanager"))

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

for workspace = 1, 9 do
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }))
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })
