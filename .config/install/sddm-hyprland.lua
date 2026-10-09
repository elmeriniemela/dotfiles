-- Dedicated greeter configuration: no desktop services or keybindings.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")

hl.monitor({ output = "", mode = "preferred", position = "auto-center-up", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto-center-down", scale = 1 })

hl.config({
    input = { kb_layout = "fi", touchpad = { natural_scroll = true } },
    general = { gaps_in = 0, gaps_out = 0, border_size = 0 },
    decoration = { rounding = 0 },
    animations = { enabled = false },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})
