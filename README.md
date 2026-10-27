# dotfiles

Personal dotfiles, covering system installation, AwesomeWM and Hyprland desktops, and development tools.

SDDM's greeter runs on Wayland using Hyprland with a Finnish keyboard layout
and a separate minimal configuration in `/etc/sddm/hyprland.lua`.
SDDM automatically logs into Hyprland on Wayland at boot. AwesomeWM on X11
remains available in the login screen's session picker, which remembers the
last session selected for manual login.

Thunderbird's startup hook exits if its Primary Password prompt is cancelled.
It checks the credential store after the native startup prompt; profiles without
a Primary Password still open normally. The installer places the AutoConfig
loader and hook in `/usr/lib/thunderbird`. This uses Thunderbird's internal APIs
and should be checked after major Thunderbird updates.

## Installation from Arch ISO

Connect to internet via Ethernet cable.

```bash
loadkeys fi
archinstall
# chroot after and enable sshd for remote install, then reboot
```

Reboot into the desktop, then
```bash
bash <(curl -fsSL https://eniemela.fi/api-v1/laptop-install.sh)
```

## Test the installer with QEMU

Install QEMU on Arch Linux:

```bash
sudo pacman -S --needed qemu-desktop
```

From the repository root, download the latest Arch ISO and create a sparse
64 GiB test disk:

```bash
mkdir -p .vm

curl -L \
  https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso \
  -o .vm/archlinux-x86_64.iso

curl -L \
  https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt \
  -o .vm/sha256sums.txt

(
  cd .vm
  sha256sum --check --ignore-missing sha256sums.txt
)

qemu-img create -f qcow2 ".vm/dotfiles.qcow2" 64G
```

The image is sparse, so it initially consumes little physical disk space.
Start the VM:

```bash
qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 8G \
  -smp 4 \
  -device virtio-vga \
  -display gtk \
  -nic user,model=virtio-net-pci \
  -drive file=".vm/dotfiles.qcow2",if=virtio,format=qcow2 \
  -cdrom ".vm/archlinux-x86_64.iso" \
  -boot once=d
```

Inside the Arch ISO, run the installer:

```bash
loadkeys fi
archinstall
```

Select `/dev/vda` as the target disk. It is the disposable virtual disk, not a
physical drive. When installation finishes, reboot:

```bash
reboot
```

Because QEMU uses `-boot once=d`, the VM should boot from the installed virtual
disk after reboot.

### Boot the installed virtual system

Immediately after installation, `reboot` should boot the installed disk because
the installer VM uses `-boot once=d`. To open it again later, run this from the
repository root.

```bash
qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 8G \
  -smp 4 \
  -device virtio-vga \
  -display gtk,clipboard=on \
  -device virtio-serial-pci \
  -chardev qemu-vdagent,id=vdagent,name=vdagent,clipboard=on \
  -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
  -nic user,model=virtio-net-pci \
  -drive file="$PWD/.vm/dotfiles.qcow2",if=virtio,format=qcow2
```

### Enable the host--guest clipboard

Install and start the clipboard agent once inside the virtual system.

```bash
sudo pacman -Syu spice-vdagent
sudo systemctl enable --now spice-vdagentd.socket
sudo reboot
```

## Sandbox VM

A separate VM for untrusted code and agents. Only `~/Odoo/src` and
`~/Downloads/isos` are shared from the host. Host loopback services such as
PostgreSQL and stunnel are not reachable, and the clipboard is not shared.

Create the disk and install it like the test VM above, using
`.vm/sandbox.qcow2` as the drive. Create the user `elmeri` first so it gets
UID 1000 and owns the shared files. Then run the laptop installer inside it.

```bash
qemu-img create -f qcow2 .vm/sandbox.qcow2 64G
qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 8G \
  -smp 4 \
  -device virtio-vga \
  -display gtk \
  -nic user,model=virtio-net-pci \
  -drive file=.vm/sandbox.qcow2,if=virtio,format=qcow2 \
  -cdrom ~/Downloads/isos/archlinux-2026.10.01-x86_64.iso \
  -boot once=d
```

Mount the shares in the guest once:

```bash
mkdir -p ~/Odoo/src ~/Downloads/isos
printf '%s\n' \
  'odoo /home/elmeri/Odoo/src virtiofs defaults,nofail 0 0' \
  'isos /home/elmeri/Downloads/isos virtiofs defaults,nofail 0 0' \
  | sudo tee -a /etc/fstab
```

Shut the guest down and snapshot the clean state:

```bash
qemu-img snapshot -c clean .vm/sandbox.qcow2
```

Start the sandbox from the repository root:

```bash
/usr/lib/virtiofsd --socket-path=.vm/odoo.sock --shared-dir="$HOME/Odoo/src" &
/usr/lib/virtiofsd --socket-path=.vm/isos.sock --shared-dir="$HOME/Downloads/isos" &
sleep 1
qemu-system-x86_64 \
  -machine q35,accel=kvm \
  -cpu host \
  -m 8G \
  -smp 4 \
  -object memory-backend-memfd,id=mem,size=8G,share=on \
  -numa node,memdev=mem \
  -device virtio-vga \
  -display gtk \
  -netdev passt,id=net0,map-host-loopback=none \
  -device virtio-net-pci,netdev=net0 \
  -chardev socket,id=odoo,path=.vm/odoo.sock \
  -device vhost-user-fs-pci,chardev=odoo,tag=odoo \
  -chardev socket,id=isos,path=.vm/isos.sock \
  -device vhost-user-fs-pci,chardev=isos,tag=isos \
  -drive file=.vm/sandbox.qcow2,if=virtio,format=qcow2
```

The `virtiofsd` processes exit when the VM stops. Revert to the clean state
while the VM is off:

```bash
qemu-img snapshot -a clean .vm/sandbox.qcow2
```

The guest can write to both shares. Code in the guest can change files that
later run on the host, such as git hooks, `.git/config`, virtualenvs and
editor settings in `~/Odoo/src`. Review changes before running them on the host,
or make the share read-only. The guest can still reach the LAN and the
Internet.

### Change the shared directories

Each share uses one name, such as `odoo`, in three places:

- the host `virtiofsd` command: `--socket-path=.vm/odoo.sock` and the
  host directory in `--shared-dir`
- the QEMU command: the `-chardev` and `-device vhost-user-fs-pci` lines
- the guest `/etc/fstab`: the tag at the start of the line and the guest
  mount point

To share a different host directory, change `--shared-dir`. For example, share
only the Odoo 19 sources:

```bash
/usr/lib/virtiofsd --socket-path=.vm/odoo.sock --shared-dir="$HOME/Odoo/src/19" &
```

To change where the guest sees it, edit the mount point in the guest
`/etc/fstab` with `sudoedit /etc/fstab`, create the directory and reboot the
guest. For example, mount the Odoo 19 sources at the same path as on the host:

```
odoo /home/elmeri/Odoo/src/19 virtiofs defaults,nofail 0 0
```

To add a share, add all three parts with a new name. To remove one, delete its
`virtiofsd` command and its two QEMU lines. The `nofail` option lets the guest
boot without it.

### Read-only shares

Add `--readonly` to the `virtiofsd` command. The host then rejects every write
from the guest:

```bash
/usr/lib/virtiofsd --socket-path=.vm/odoo.sock --shared-dir="$HOME/Odoo/src" --readonly &
```

Also use `ro` in the guest `/etc/fstab`, so guest programs see the share as
read-only before they try to write:

```
odoo /home/elmeri/Odoo/src virtiofs ro,nofail 0 0
```

A read-only `~/Odoo/src` with a writable `~/Downloads/isos` gives the guest
one place to hand files back to the host.
