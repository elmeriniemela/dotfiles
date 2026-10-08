# Quickshell bar

Start with `quickshell -p ~/.config/hypr/quickshell --no-duplicate`.
Changes to QML reload automatically. Hyprland already starts this configuration.

- `shell.qml` places one panel per monitor.
- `Theme.qml` contains shared colors, font, and height.
- `Workspaces.qml`, `Clock.qml`, `Indicators.qml`, and `Tray.qml` define widgets.
- `StatusButton.qml` provides icons, text, hover/press feedback, and accessibility descriptions. Hover tooltips are disabled.
- `Services.qml` shares device state and polling across all monitors.
- `BatteryAlerts.qml` sends alerts once per discharge/charge cycle; `AlertLogic.js` holds its pure transition logic.

To add a widget, create a QML component and insert it into the panel or the indicator row.
Pass `services` to components that need shared state rather than polling per monitor.
Icons in `assets/` are copied from the active Awesome theme.

Workspace click switches; Super + click sends the focused window without following.
Clock click toggles a Monday-first calendar; Escape or clicking outside on any monitor closes it.
Scroll over the open calendar to change months: up goes back, down goes forward.
While open, transparent input layers consume the dismissal click, including clicks on the bar.
Brightness scrolling changes the laptop backlight by 5%.
Microphone/output clicks open pwvucontrol's input/output device tabs.
Notification click pauses Dunst; resuming discards queued notifications without deleting history.
Tray icons pass clicks, menus, and scrolling to their applications.
Tray icons follow the system icon theme; application-provided colors are preserved.

Dependencies: Quickshell (Qt Quick Controls, PipeWire and UPower integrations),
`brightnessctl`, `pwvucontrol`, `dunstctl`, `notify-send`, `hyprctl`, and Python/Rofi for shortcut help.
The backlight device is `intel_backlight`; change it in Services.qml for other hardware.
Mute LEDs are optional and use brightnessctl's existing device permissions; no sudo is used.
Battery alerts: low at <=15%, critical at <=5%, full on entering FullyCharged.
Dunst's own pause/urgency rules determine whether alerts are immediately displayed.

Check runtime errors in the Quickshell logs and `hyprctl configerrors` after editing.
