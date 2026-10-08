"""Show the current Hyprland bindings as a searchable, read-only list."""

import json
import subprocess
import sys


bindings = json.loads(subprocess.check_output(["hyprctl", "-j", "binds"], text=True))
modifiers = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]
key_names = {
    "Return": "Enter",
    "space": "Space",
    "mouse:272": "Left mouse",
    "mouse:273": "Right mouse",
}
rows = []
for binding in bindings:
    keys = [name for mask, name in modifiers if binding["modmask"] & mask]
    key = binding["key"] or f"Keycode {binding['keycode']}"
    keys.append(key_names.get(key, key))
    shortcut = " + ".join(keys)
    description = binding["description"] or "No description provided"
    if binding["submap"]:
        shortcut = f"[{binding['submap']}] {shortcut}"
    rows.append(f"{shortcut:<36}  {description}")

listing = "\n".join(rows) + "\n"
if "--print" in sys.argv:
    print(listing, end="")
else:
    subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", "Shortcuts", "-mesg", "Type to search · Esc to close", "-no-custom"],
        input=listing,
        text=True,
        stdout=subprocess.DEVNULL,
        check=False,
    )
