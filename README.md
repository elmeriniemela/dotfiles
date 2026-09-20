# dotfiles

## Installation from Arch ISO

Connect to internet via Ethernet cable.

```bash
loadkeys fi
archinstall
```

Boot into desktop, then
```bash
# Run .install.sh in a child shell on a live USB environment.
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
