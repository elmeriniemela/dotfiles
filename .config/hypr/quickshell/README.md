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
Brightness scrolling changes the laptop backlight by 1%.
Battery click opens charge level, full capacity, cycles, remaining time, power
draw/charging rate, charge limits, and the current firmware power mode. A bolt
in the bar's battery icon indicates external power, including while holding at
the charge limit. Battery-only operation uses a plain battery icon.
The battery and brightness panels share `BarPopup.qml` for positioning and
Escape/outside-click dismissal. Extra battery details refresh every five seconds
only while the panel is open; unsupported readings show “—”. TLP manages power
policy and charge limits; the panel displays them without changing them.
Click brightness to open backlight and color-temperature sliders; Escape or an
outside click closes the popup. Temperature ranges from 1000 K (warm) to 6500 K
(neutral, filter disabled) and applies to all displays through hyprsunset.
The backlight slider controls `intel_backlight` from 1–100%. Values follow the
current session state, including changes made with brightness keys or hyprctl;
temperature changes last until hyprsunset restarts or its next scheduled profile.
Microphone/output clicks open pwvucontrol's input/output device tabs.
Notification click pauses Dunst; resuming discards queued notifications without deleting history.
Tray icons pass clicks, menus, and scrolling to their applications.
Tray icons follow the system icon theme; application-provided colors are preserved.
The power button at the right opens `archlinux-logout`.
The record button runs `../screen-record.sh` to start or stop a region recording; it shows a red REC while `wf-recorder` runs.

Dependencies: Quickshell (Qt Quick Controls, PipeWire and UPower integrations),
`brightnessctl`, `hyprsunset`, `pwvucontrol`, `dunstctl`, `notify-send`, `hyprctl`, `wf-recorder`/`slurp` for recording,
and Python/Rofi for shortcut help.
The backlight device is `intel_backlight`; change it in Services.qml for other hardware.
Mute LEDs are optional and use brightnessctl's existing device permissions; no sudo is used.
Battery alerts: low at <=15%, critical at <=5%, full on entering FullyCharged.
Dunst's own pause/urgency rules determine whether alerts are immediately displayed.

Check runtime errors in the Quickshell logs and `hyprctl configerrors` after editing.
