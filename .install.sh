#!/usr/bin/bash
set -euxo pipefail

sudo pacman -S --needed git
DOTFILESCMD=(/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME")

if [[ -d "$HOME/.dotfiles" ]]; then
    "${DOTFILESCMD[@]}" pull
else
    git clone --bare https://github.com/elmeriniemela/dotfiles.git "$HOME/.dotfiles"
fi

"${DOTFILESCMD[@]}" checkout
"${DOTFILESCMD[@]}" config --local status.showUntrackedFiles no
"${DOTFILESCMD[@]}" submodule update --init --recursive

rm -f ~/.bashrc
rm -f ~/.bash_profile
sudo rm -f /root/.bash_profile
sudo rm -f /root/.bashrc

base_packages=(
    base-devel              # Build tools required by AUR packages.
    openssh                 # SSH client and server.
    sudo                    # Run administrative commands.
    cronie                  # Cron scheduler.
    rsync                   # Efficient file synchronization.
    ncdu                    # Interactive disk-usage viewer.
    htop                    # Interactive process monitor.
    openvpn                 # Personal VPN client.
    bash-completion         # Shell completion definitions.
    tmux                    # Terminal multiplexer.
    unrar                   # Extract RAR archives.
    unzip                   # Extract ZIP archives.
    zip                     # Create ZIP archives.
    ffmpeg                  # Media encoding and conversion.
    wget                    # Command-line downloads.
    syncthing               # File synchronization service.
    reflector               # Arch mirrorlist management.
    python-colorama         # Terminal color support for bootstrap-linux.
    curl                    # Command-line HTTP client.
    less                    # Pager for terminal output.
    plocate                 # Fast filename search index.
    man-db                  # Manual-page database and reader.
    dnsutils                # DNS troubleshooting tools.
    vim                     # Terminal text editor.
    certbot                 # Let's Encrypt certificate client.
    certbot-dns-cloudflare  # Cloudflare DNS challenge plugin for Certbot.
    composer                # PHP dependency manager.
    npm                     # JavaScript package manager.
    ripgrep                 # Fast recursive text search.
    jq                      # JSON command-line processor.
    7zip                    # Archive creation and extraction.
)
sudo pacman -S --noconfirm --needed "${base_packages[@]}"
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/pacman.conf" /etc/pacman.conf

if ! command -v yay >/dev/null; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    sudo pacman -Syy
    sudo pacman -S --noconfirm --needed yay  # Install the AUR package helper.
fi

sudo systemctl enable cronie systemd-timesyncd
sudo systemctl start cronie systemd-timesyncd
sudo sed -i '/^#en_US.UTF-8/s/^#//g' /etc/locale.gen
sudo sed -i '/^#fi_FI.UTF-8/s/^#//g' /etc/locale.gen
sudo locale-gen
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/wheel_group" /etc/sudoers.d/wheel_group
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/vconsole.conf" /etc/vconsole.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/locale.conf" /etc/locale.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/laptop-install/99-sysctl.conf" /etc/sysctl.d/99-sysctl.conf

laptop_packages=(
    alacritty                       # GPU-accelerated terminal emulator.
    awesome                         # Window manager.
    betterlockscreen                # Lock-screen manager.
    brave-bin                       # Privacy-focused web browser.
    cloc                            # Source line counter.
    default-cursors                 # Default X11 cursor theme.
    xfce4-clipman-plugin            # Clipboard manager.
    xdg-utils                       # Open files with default applications.
    rofi                            # Application launcher.
    tlp                             # Laptop power management.
    rofi-calc                       # Calculator mode for Rofi.
    picom                           # X11 compositor.
    signal-desktop                  # Signal desktop client.
    udisks2                         # Disk and removable-media service.
    gvfs                            # Virtual filesystem support.
    udiskie                         # Automatic removable-media mounting.
    python-qdarkstyle               # Dark Qt style for Electrum.
    python-coverage                 # Python test coverage reporting.
    ruff                            # Python linter and formatter.
    bluez                           # Bluetooth protocol stack.
    bluez-libs                      # Bluetooth libraries.
    bluez-tools                     # Bluetooth management tools.
    bluez-utils                     # Bluetooth command-line utilities.
    thunar                          # File manager.
    thunar-archive-plugin           # Archive integration for Thunar.
    thunar-volman                   # Volume management for Thunar.
    pavucontrol                     # PulseAudio/PipeWire volume control.
    openconnect                     # Work VPN client.
    mermaid-cli                     # Render Mermaid diagrams.
    thunderbird                     # Email client.
    veracrypt                       # Encrypted-volume manager.
    wireless-regdb                  # Wireless regulatory database.
    ventoy-bin                      # Multi-ISO bootable USB creator.
    gocryptfs                       # Encrypted filesystem tool.
    papirus-icon-theme              # Icon theme.
    hicolor-icon-theme              # Freedesktop fallback icons.
    tumbler                         # File-manager thumbnail service.
    firefox                         # Web browser.
    ffmpegthumbnailer               # Video thumbnails for Thunar.
    flameshot                       # Screenshot tool.
    fontconfig                      # Font configuration library.
    font-manager                    # Font preview and management UI.
    fprintd                         # Fingerprint authentication daemon.
    git-lfs                         # Git large-file support.
    alsa-card-profiles              # ALSA card profile definitions.
    alsa-firmware                   # Firmware for ALSA devices.
    alsa-lib                        # ALSA core library.
    alsa-plugins                    # ALSA compatibility plugins.
    alsa-topology-conf              # ALSA topology configuration.
    alsa-ucm-conf                   # ALSA use-case configuration.
    alsa-utils                      # ALSA utilities such as alsamixer.
    sof-firmware                    # Intel Sound Open Firmware blobs.
    pipewire                        # Audio and video server.
    pipewire-alsa                   # ALSA support through PipeWire.
    pipewire-audio                  # PipeWire audio components.
    pipewire-pulse                  # PulseAudio compatibility layer.
    pipewire-session-manager        # PipeWire session management.
    pipewire-zeroconf               # PipeWire mDNS discovery.
    polkit                          # Privilege authorization framework.
    lxsession                       # Graphical Polkit authentication agent.
    postgresql                      # PostgreSQL database server.
    postgresql-libs                 # PostgreSQL client libraries.
    postgresql-old-upgrade          # PostgreSQL upgrade tools.
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
    ttf-anonymous-pro               # Anonymous Pro programming font.
    ttf-bitstream-vera              # Bitstream Vera font family.
    ttf-caladea                     # Cambria-compatible font.
    ttf-carlito                     # Calibri-compatible font.
    ttf-cascadia-code               # Cascadia Code programming font.
    ttf-cormorant                   # Cormorant serif font.
    ttf-croscore                    # Chrome OS core fonts.
    ttf-dejavu                      # Broad Unicode font family.
    ttf-droid                       # Android Droid font family.
    ttf-eurof                       # Eurofurence display font.
    ttf-fantasque-sans-mono         # Fantasque Sans Mono font.
    ttf-fira-code                   # Fira Code programming font.
    ttf-fira-mono                   # Fira Mono font.
    ttf-fira-sans                   # Fira Sans font.
    ttf-font-awesome                # Font Awesome icon font.
    ttf-hack                        # Hack programming font.
    ttf-ibm-plex                    # IBM Plex font family.
    ttf-inconsolata                 # Inconsolata programming font.
    ttf-iosevka-nerd                # Iosevka Nerd Font.
    ttf-jetbrains-mono              # JetBrains Mono font.
    ttf-jetbrains-mono-nerd         # JetBrains Mono Nerd Font.
    ttf-lato                        # Lato font family.
    ttf-liberation                  # Microsoft-metric-compatible fonts.
    ttf-linux-libertine             # Linux Libertine font family.
    ttf-linux-libertine-g           # Graphite-enabled Linux Libertine.
    ttf-monofur                     # Monofur programming font.
    ttf-ms-fonts                    # Microsoft core fonts.
    ttf-nerd-fonts-symbols          # Nerd Font icon glyphs.
    ttf-nerd-fonts-symbols-common   # Common Nerd Font symbols.
    ttf-nerd-fonts-symbols-mono     # Monospaced Nerd Font symbols.
    ttf-opensans                    # Open Sans font family.
    ttf-roboto                      # Roboto font family.
    ttf-roboto-mono                 # Roboto Mono font.
    ttf-sourcecodepro-nerd          # Source Code Pro Nerd Font.
    ttf-ubuntu-font-family          # Ubuntu font family.
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
)
sudo pacman -S --noconfirm --needed "${laptop_packages[@]}"

aur_packages=(
    blueberry               # Bluetooth configuration UI.
    acpilight               # Backlight control utility.
    xautolock               # Automatically lock inactive X11 sessions.
    archlinux-logout-git    # Arch Linux logout scripts.
    arcolinux-logout        # Graphical logout dialog.
    wkhtmltopdf-bin         # HTML-to-PDF converter.
)
yay -S --noconfirm --needed "${aur_packages[@]}"

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
sudo systemctl enable --now NetworkManager bluetooth tlp upower
systemctl --user enable --now ssh-agent.service
systemctl --user daemon-reload
