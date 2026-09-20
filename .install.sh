#!/usr/bin/bash
set -euxo pipefail
sudo systemctl enable --now systemd-timesyncd
sudo pacman -S --needed git reflector vim
dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

if [[ -d "$HOME/.dotfiles" ]]; then
    dotfiles pull
else
    git clone --bare https://github.com/elmeriniemela/dotfiles.git "$HOME/.dotfiles"
fi

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
dotfiles submodule update --init --recursive

rm -f ~/.bashrc
rm -f ~/.bash_profile
sudo rm -f /root/.bash_profile
sudo rm -f /root/.bashrc

if [[ ! -f /etc/pacman.d/chaotic-mirrorlist ]]; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
fi

sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/pacman.conf" /etc/pacman.conf

sudo sed -i '/^#en_US.UTF-8/s/^#//g' /etc/locale.gen
sudo sed -i '/^#fi_FI.UTF-8/s/^#//g' /etc/locale.gen
sudo locale-gen
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/wheel_group" /etc/sudoers.d/wheel_group
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/vconsole.conf" /etc/vconsole.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/locale.conf" /etc/locale.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/99-sysctl.conf" /etc/sysctl.d/99-sysctl.conf

laptop_packages=(
    7zip                            # Archive creation and extraction.
    alacritty                       # GPU-accelerated terminal emulator.
    awesome                         # Window manager.
    base-devel                      # Build tools required by AUR packages.
    bash-completion                 # Shell completion definitions.
    betterlockscreen                # Lock-screen manager.
    blueman                         # Bluetooth manager and tray applet.
    brave-bin                       # Privacy-focused web browser.
    brightnessctl                   # Backlight control utility.
    certbot                         # Let's Encrypt certificate client.
    certbot-dns-cloudflare          # Cloudflare DNS challenge plugin for Certbot.
    cloc                            # Source line counter.
    composer                        # PHP dependency manager.
    cronie                          # Cron scheduler.
    curl                            # Command-line HTTP client.
    dnsutils                        # DNS troubleshooting tools.
    ffmpeg                          # Media encoding and conversion.
    htop                            # Interactive process monitor.
    jq                              # JSON command-line processor.
    less                            # Pager for terminal output.
    man-db                          # Manual-page database and reader.
    ncdu                            # Interactive disk-usage viewer.
    npm                             # JavaScript package manager.
    openssh                         # SSH client and server.
    openvpn                         # Personal VPN client.
    plocate                         # Fast filename search index.
    python-colorama                 # Terminal color support for bootstrap-linux.
    ripgrep                         # Fast recursive text search.
    rsync                           # Efficient file synchronization.
    syncthing                       # File synchronization service.
    tmux                            # Terminal multiplexer.
    unrar                           # Extract RAR archives.
    unzip                           # Extract ZIP archives.
    wget                            # Command-line downloads.
    zip                             # Create ZIP archives.
    default-cursors                 # Default X11 cursor theme.
    xfce4-clipman-plugin            # Clipboard manager.
    xdg-utils                       # Open files with default applications.
    rofi                            # Application launcher.
    tlp                             # Laptop power management.
    rofi-calc                       # Calculator mode for Rofi.
    picom                           # X11 compositor.
    signal-desktop                  # Signal desktop client.
    sddm                            # The Simple Desktop Display Manager.
    udisks2                         # Disk and removable-media service.
    gvfs                            # Virtual filesystem support.
    udiskie                         # Automatic removable-media mounting.
    python-qdarkstyle               # Dark Qt style for Electrum.
    python-coverage                 # Python test coverage reporting.
    ruff                            # Python linter and formatter.
    bluez                           # Bluetooth protocol stack.
    bluez-tools                     # Bluetooth management tools.
    bluez-utils                     # Bluetooth command-line utilities.
    thunar                          # File manager.
    thunar-archive-plugin           # Archive integration for Thunar.
    thunar-volman                   # Volume management for Thunar.
    pavucontrol                     # PulseAudio/PipeWire volume control.
    mermaid-cli                     # Render Mermaid diagrams.
    thunderbird                     # Email client.
    veracrypt                       # Encrypted-volume manager.
    wireless-regdb                  # Wireless regulatory database.
    ventoy-bin                      # Multi-ISO bootable USB creator.
    gocryptfs                       # Encrypted filesystem tool.
    papirus-icon-theme              # Icon theme.
    tumbler                         # File-manager thumbnail service.
    firefox                         # Web browser.
    ffmpegthumbnailer               # Video thumbnails for Thunar.
    flameshot                       # Screenshot tool.
    fontconfig                      # Font configuration library.
    font-manager                    # Font preview and management UI.
    fprintd                         # Fingerprint authentication daemon.
    git-lfs                         # Git large-file support.
    alsa-firmware                   # Firmware for ALSA devices.
    alsa-plugins                    # ALSA compatibility plugins.
    alsa-topology-conf              # ALSA topology configuration.
    alsa-ucm-conf                   # ALSA use-case configuration.
    alsa-utils                      # ALSA utilities such as alsamixer.
    sof-firmware                    # Intel Sound Open Firmware blobs.
    pipewire-alsa                   # ALSA support through PipeWire.
    pipewire-audio                  # PipeWire audio components.
    pipewire-pulse                  # PulseAudio compatibility layer.
    pipewire-zeroconf               # PipeWire mDNS discovery.
    polkit                          # Privilege authorization framework.
    lxsession                       # Graphical Polkit authentication agent.
    postgresql                      # PostgreSQL database server.
    powertop                        # Power-consumption diagnostics.
    networkmanager                  # Network connection manager.
    network-manager-applet          # NetworkManager tray applet.
    networkmanager-openconnect      # OpenConnect NetworkManager plugin.
    networkmanager-openvpn          # OpenVPN NetworkManager plugin.
    networkmanager-pptp             # PPTP NetworkManager plugin.
    networkmanager-vpnc             # VPNC NetworkManager plugin.
    nm-connection-editor            # NetworkManager connection editor.
    arandr                          # Display-layout configuration UI.
    laptop-detect                   # Detect laptop hardware.
    lxappearance                    # GTK theme configuration UI.
    upower                          # Battery and power information service.
    visual-studio-code-bin          # Visual Studio Code binary distribution.
    vlc                             # Media player.
    sshfs                           # Mount filesystems over SSH.
    sshpass                         # Non-interactive SSH password input.
    sshuttle                        # VPN-like SSH tunnel.
    wireplumber                     # PipeWire policy and session manager.
    xarchiver                       # Archive manager UI.
    xclip                           # X11 clipboard command-line tool.
    xdg-user-dirs                   # Standard user-directory management.
    xmlsec                          # XML encryption and signature tooling.
    yt-dlp                          # Video downloader.
    zbar                            # Barcode and QR-code reader.
    zoom                            # Video-conferencing client.
    ttf-caladea                     # Cambria-compatible font.
    ttf-carlito                     # Calibri-compatible font.
    ttf-droid                       # Android Droid font family.
    inter-font                      # Awesome window-manager UI font.
    noto-fonts                      # Broad Unicode font coverage.
    noto-fonts-emoji                # Emoji font support.
    discord                         # Discord desktop client.
    dunst                           # Lightweight notification daemon.
    dconf                           # GTK settings database.
    feh                             # Lightweight image viewer.
    xorg-xkill                      # Kill an X11 client interactively.
    xfce4-taskmanager               # Task manager for Ctrl+Shift+Esc.
    nomacs                          # Image viewer.
    gparted                         # Graphical partition editor.
    libreoffice-fresh               # Office suite.
    vlc-plugin-ffmpeg               # FFmpeg codec support for VLC.
    breeze-gtk                      # Dark GTK theme.
    xdg-desktop-portal              # Desktop integration portal.
    xdg-desktop-portal-gtk          # GTK portal backend.
    xss-lock                        # Idle and suspend screen locker.
    yay                             # Install the AUR package helper.
)

sudo reflector \
  --age 24 \
  --completion-percent 100 \
  --protocol https \
  --latest 50 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist

sudo pacman -Syy --noconfirm --needed "${laptop_packages[@]}"

sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/backlight.rules" /etc/udev/rules.d/backlight.rules
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/hosts" /etc/hosts
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/environment" /etc/environment
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/UPower.conf" /etc/UPower/UPower.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/awesome_sddm.conf" /etc/sddm.conf.d/awesome_sddm.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/awesome-portals.conf" /etc/xdg-desktop-portal/awesome-portals.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/dconf/profile/user" /etc/dconf/profile/user
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/dconf/local.d/00-settings" /etc/dconf/db/local.d/00-settings
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/sudo" /etc/pam.d/sudo
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/polkit-1" /etc/pam.d/polkit-1
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/i3lock" /etc/pam.d/i3lock
sudo install -D -o root -g root -m 755 "$HOME/.config/laptop-install/lxlock" /usr/local/bin/lxlock
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/ssh-agent-fprint-askpass.conf" /etc/systemd/user/ssh-agent.service.d/fprint-askpass.conf
sudo install -D -o root -g root -m 755 "$HOME/.config/laptop-install/ssh-askpass-fprint" /usr/local/bin/ssh-askpass-fprint
# This must remain root-owned because every interactive root shell sources it.
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/global.bashrc" /etc/bash.bashrc.local
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/bash.bashrc" /etc/bash.bashrc
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/sddm" /etc/pam.d/sddm

sudo dconf update
sudo udevadm control --reload-rules
sudo groupadd -r nopasswdlogin || true
sudo usermod -a -G video elmeri
sudo usermod -a -G nopasswdlogin elmeri
sudo systemctl enable cronie NetworkManager bluetooth tlp upower sddm
systemctl --user enable ssh-agent.service
systemctl --user daemon-reload
