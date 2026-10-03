# Jabra and Google Meet audio

Analysis performed on 2026-09-21. No system settings were changed during the analysis.

## Summary

The problem appears to be a combination of device routing and an unreliable Bluetooth profile transition, rather than a missing microphone permission.

Bluetooth exposes the Jabra in two substantially different modes:

| Mode | Purpose | Microphone | Playback quality |
| --- | --- | --- | --- |
| A2DP | Music/headphones | No | High-quality stereo |
| HSP/HFP with mSBC | Calls/headset | Yes | Lower-quality call audio |

The screenshots show that the correct call mode and its corresponding headset port had to be selected manually. WirePlumber is already configured to do this automatically: when Meet opens the Jabra microphone, it should switch from A2DP to HSP/HFP after about 0.5 seconds.

The intended path is:

```text
Meet "Default" device
        |
        v
PipeWire default Jabra mic
        |
        v
WirePlumber notices microphone use
        |
        v
A2DP -> HSP/HFP mSBC
        |
        v
BlueZ -> Intel AX211 Bluetooth -> Jabra
```

Several things can disrupt that path.

## Evidence from this system

- The Jabra pairing is healthy: paired, bonded and trusted.
- Meet has microphone permission in Brave.
- WirePlumber's Bluetooth auto-switch, profile restoration, route restoration and follow-default behavior are all enabled.
- The manual mSBC/headset-port selections are now saved in WirePlumber's state.
- There is no explicitly configured persistent default input or output.
- With the Jabra disconnected, the current defaults are:
  - Input: laptop digital microphone
  - Output: ASUS monitor over HDMI
- Brave remembers two ranked microphone identifiers. It was not possible to conclusively decode which one Meet is selecting, but it may be selecting a specific device instead of the system default.
- At initial connection, BlueZ reported:

  ```text
  a2dp-sink profile connect failed ... Device or resource busy
  ```

- WirePlumber logged 71 Jabra Bluetooth transport failures or transitions between September 7 and September 21. Some are probably expected when changing profiles or powering off the headset, so that count alone does not prove 71 user-visible failures.
- At `10:32:54`, immediately before the screenshots, the HFP input and output entered an error state and the kernel reported an SCO packet for an unknown connection. This may have been caused by the manual codec change, but it confirms that the troublesome layer is the Bluetooth call transport.
- TLP currently permits autosuspend on the Intel AX211 Bluetooth interface after two seconds:
  - `USB_EXCLUDE_BTUSB=0`
  - USB power control: `auto`
- There is no Jabra Link USB adapter currently attached.
- Relevant software versions at the time of analysis:
  - BlueZ `5.87-2`
  - PipeWire `1.6.8`
  - WirePlumber `0.5.17`
  - Brave `1.95.104`

## Recommended changes

### 1. Make the Jabra the persistent PipeWire default and make Meet use Default

First connect the Jabra, then run:

```bash
wpctl status
```

The output contains several numbered sections. Only two entries are needed:

1. Under **Audio -> Sinks**, find `Jabra Evolve2 65`. A sink is a playback destination, so this is the number for the headphones.
2. Under **Audio -> Filters**, find the `bluez_input...` entry whose type at the right is `[Audio/Source]`. An audio source is a recording source, so this is the number for the microphone.

For example, after the reboot on 2026-09-22 the relevant part of the status was:

```text
Audio
 ├─ Devices:
 │     100. Jabra Evolve2 65                    [bluez5]
 │
 ├─ Sinks:
 │  *   89. Jabra Evolve2 65                    [vol: 0.73]
 │
 ├─ Sources:
 │     114. Jabra Evolve2 65                    [vol: 0.60]
 │
 ├─ Filters:
 │     102. bluez_capture_internal...           [Stream/Input/Audio/Internal]
 │  *  105. bluez_input...                      [Audio/Source]
```

Read that example as follows:

- `89` is the output ID because it is the Jabra entry under **Sinks**.
- `105` is the input ID because it is the Jabra/BlueZ entry marked `[Audio/Source]` under **Filters**.
- Do not use `100`: it is the Bluetooth card under **Devices**, not an audio input or output.
- Do not use `114`: it is the internal Bluetooth microphone transport. WirePlumber connects applications through the filter instead.
- Do not use `102`: `[Stream/Input/Audio/Internal]` identifies another internal part of the filter.
- Do not use numbers under **Streams**: those belong to running applications such as Brave.
- A `*` means the node is the current default. It does not necessarily mean it has been saved as the persistent configured default.

For the example above, save the defaults with:

```bash
wpctl set-default 89   # Jabra output from the Sinks section
wpctl set-default 105  # Jabra microphone marked [Audio/Source]
```

The numbers are temporary and can change after reconnecting the headset or rebooting. Always read the current numbers before running `wpctl set-default`. The command saves the node's stable name, so the numbers do not need to remain the same afterward.

If an entry is unclear, inspect it before selecting it:

```bash
wpctl inspect 89 | rg 'media.class|node.name'
wpctl inspect 105 | rg 'media.class|node.name'
```

The output should identify the first node as `Audio/Sink` with a `bluez_output...` name and the second as `Audio/Source` with a `bluez_input...` name.

Run `wpctl status` again after setting both defaults. The bottom **Default Configured Devices** section should no longer be empty and should list the configured Jabra audio sink and source. This is the important persistence check; the stars alone are not sufficient.

WirePlumber remembers these selections across restarts. When the Jabra is absent, it uses another available device; when the Jabra reconnects, it becomes preferred again. Existing streams should follow because `linking.follow-default-target` is enabled.

In Meet, select the device named **Default** for both microphone and speakers instead of selecting a particular Jabra instance. This also prevents Meet from remaining attached to the ASUS monitor's HDMI output.

References:

- [WirePlumber `wpctl` documentation](https://pipewire.pages.freedesktop.org/wireplumber/man/wpctl.html)
- [Google Meet audio device help](https://support.google.com/meet/answer/10409699)

### 2. Disable USB autosuspend only for Bluetooth

The effective TLP setting is currently:

```ini
USB_EXCLUDE_BTUSB=0
```

Test a small TLP drop-in containing:

```ini
# /etc/tlp.d/10-bluetooth.conf
USB_EXCLUDE_BTUSB=1
```

TLP describes this setting as intended to solve unstable Bluetooth connections. The tradeoff is a small potential increase in battery usage.

For this repository, the maintainable implementation would be one tracked file containing that setting and one simple `install` command in `.install.sh`. Copying and maintaining the complete `/etc/tlp.conf` would be unnecessary.

After applying the setting, `tlp-stat -u` should show the Intel Bluetooth device as `control = on`. On this system it remained `auto` because the `btusb` kernel driver enabled autosuspend independently. The repository therefore also installs this module option and rebuilds the initramfs:

```text
# /etc/modprobe.d/btusb.conf
options btusb enable_autosuspend=0
```

After rebooting, `/sys/module/btusb/parameters/enable_autosuspend` should contain `N` and `tlp-stat -u` should report `control = on` for the Intel AX211 Bluetooth device.

References:

- [TLP Bluetooth troubleshooting](https://linrunner.de/tlp/faq/radio.html)
- [TLP USB settings](https://linrunner.de/tlp/settings/usb.html)

### 3. Test without Bluetooth multipoint

For several calls, turn off Bluetooth on the phone or disconnect the Jabra from its second device.

The Evolve2 65 supports two simultaneous device connections, but only one device can play audio at once. That could explain the `Device or resource busy` event, although it could also be an internal BlueZ race.

Reference: [Jabra multipoint support information](https://www.jabra.com/en-emea/support/export/faq?groupid=1558&id=915fa082-b4cc-43db-934b-09d441a4d1fd)

### 4. Prefer the Jabra Link 380/390 adapter if available

This is likely the most reliable overall solution. The Link adapter presents a managed USB audio device to Linux and avoids the native BlueZ A2DP/HFP profile transition.

Jabra's computer setup recommends the supplied Link 380/390 and selecting it for input and output. Jabra also recommends updating the headset firmware.

Reference: [Jabra Evolve2 65 manual](https://www.jabra.com/_/media/Jabra_VXi_Product-Documentation/Jabra-Evolve2-65/User-Manuals/RevF/Jabra-Evolve2-65_User-Manual_EN_English_RevF.pdf)

### 5. Last resort: always use call mode

If reliability matters more than music quality, disable WirePlumber's automatic switching and leave the headset permanently in HSP/HFP mSBC:

```bash
wpctl settings --save bluetooth.autoswitch-to-headset-profile false
```

Then select the mSBC headset profile once.

This removes the fragile A2DP-to-HFP transition, but all audio remains lower-quality mono call audio. This should only be used if the default-device and autosuspend changes do not solve the problem.

## Additional observations

BlueZ `5.87` has recent reports of intermittent A2DP failures involving the same `Unable to load LastUsed` message and the same BlueZ/PipeWire versions. The reported hardware and Bluetooth direction differ, so this is suggestive rather than proof. Keep Arch updated normally rather than pinning or partially downgrading BlueZ.

Reference: [BlueZ issue #2453](https://github.com/bluez/bluez/issues/2453)

WirePlumber also warns that RTKit is missing, but that affects real-time scheduling and possible latency, not device selection or Bluetooth profile choice. It is not considered the cause.

## Proposed test order

1. Save the Jabra as both PipeWire defaults.
2. Set Meet input and output to **Default**.
3. Add the TLP Bluetooth autosuspend exclusion.
4. Test several calls with the phone disconnected.
5. If failures remain, use the Jabra Link adapter or permanent call mode.
