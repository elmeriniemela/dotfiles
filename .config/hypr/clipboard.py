"""Select a history entry without changing the clipboard when cancelled."""

import subprocess


def main():
    entries = subprocess.check_output(["cliphist", "list"])
    selection = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", "Clipboard", "-display-columns", "2", "-no-custom"],
        input=entries,
        stdout=subprocess.PIPE,
        check=False,
    )
    if selection.returncode != 0 or not selection.stdout.strip():
        return
    content = subprocess.check_output(["cliphist", "decode"], input=selection.stdout)
    subprocess.run(["wl-copy"], input=content, check=True)


if __name__ == "__main__":
    main()
