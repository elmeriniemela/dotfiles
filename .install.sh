#!/usr/bin/bash
set -euxo pipefail

sudo -v
(
    set +x
    while sleep 60; do
        sudo -n -v || exit
    done
) &
sudo_keepalive_pid=$!
trap 'kill "$sudo_keepalive_pid" 2>/dev/null || true' EXIT

sudo systemctl enable --now systemd-timesyncd
sudo pacman -S --noconfirm --needed git reflector vim
dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

if [[ -d "$HOME/.dotfiles" ]]; then
    dotfiles pull --rebase --autostash
else
    git clone --bare https://github.com/elmeriniemela/dotfiles.git "$HOME/.dotfiles"
fi

dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
dotfiles submodule update --init --recursive

sudo install -D -o root -g root -m 644 "$HOME/.config/install/global.bashrc" /etc/global.bashrc
sudo install -D -o root -g root -m 644 "$HOME/.config/install/bash.bashrc" /etc/bash.bashrc

rm -f ~/.bashrc
rm -f ~/.bash_profile
sudo rm -f /root/.bash_profile
sudo rm -f /root/.bashrc

sudo sed -i '/^#en_US.UTF-8/s/^#//g' /etc/locale.gen
sudo sed -i '/^#fi_FI.UTF-8/s/^#//g' /etc/locale.gen
sudo locale-gen
sudo groupadd -r nopasswdlogin || true
sudo usermod -a -G video elmeri
sudo usermod -a -G nopasswdlogin elmeri

sudo install -D -o root -g root -m 644 "$HOME/.config/install/wheel_group" /etc/sudoers.d/wheel_group
sudo install -D -o root -g root -m 644 "$HOME/.config/install/vconsole.conf" /etc/vconsole.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/locale.conf" /etc/locale.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/99-sysctl.conf" /etc/sysctl.d/99-sysctl.conf

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
    ripgrep                         # Fast recursive text search.
    rtkit                           # Real-time scheduling for PipeWire.
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
    pwvucontrol                     # PulseAudio/PipeWire volume control.
    mermaid-cli                     # Render Mermaid diagrams.
    thunderbird                     # Email client.
    veracrypt                       # Encrypted-volume manager.
    wireless-regdb                  # Wireless regulatory database.
    ventoy-bin                      # Multi-ISO bootable USB creator.
    gocryptfs                       # Encrypted filesystem tool.
    grim                            # Wayland screenshots.
    hypridle                        # Hyprland idle and suspend locking.
    hyprland                        # Wayland desktop session.
    hyprlock                        # Hyprland screen locker.
    hyprpaper                       # Hyprland wallpaper manager.
    hyprpolkitagent                 # Wayland Polkit authentication agent.
    cliphist
    quickshell
    qt5-wayland                     # Qt 5 Wayland support.
    qt6-wayland                     # Qt 6 Wayland support.
    slurp                           # Wayland screen-region selection.
    waybar                          # Hyprland status bar and system tray.
    wf-recorder                     # Wayland screen recorder.
    wl-clipboard                    # Wayland clipboard commands.
    xdg-desktop-portal-hyprland     # Hyprland screen-sharing portal.
    papirus-icon-theme              # Icon theme.
    tumbler                         # File-manager thumbnail service.
    libgepub                        # EPUB thumbnails for Tumbler.
    libgsf                          # OpenDocument thumbnails for Tumbler.
    libopenraw                      # RAW image thumbnails for Tumbler.
    poppler-glib                    # PDF thumbnails for Tumbler.
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
    pipewire-libcamera
    polkit                          # Privilege authorization framework.
    lxsession                       # Graphical Polkit authentication agent.
    postgresql                      # PostgreSQL database server.
    chromium                        # Odoo browser tour tests.
    libxml2                         # Odoo XML processing.
    pgvector                        # PostgreSQL vector extension for Odoo.
    pkgconf                         # pkg-config implementation for Odoo dependencies.
    pwgen                           # Password generator used by Odoo setup.
    sassc                           # Compile Odoo SCSS bundles.
    python-asn1crypto               # ASN.1 parsing for cryptographic data.
    python-babel                    # Locale data and message translation.
    python-cbor2                    # CBOR encoding and decoding.
    python-chardet                  # Text encoding detection.
    python-cryptography             # Cryptographic primitives for Python.
    python-dateutil                 # Date parsing and recurrence rules.
    python-decorator                # Python function decorator helpers.
    python-docutils                 # reStructuredText document processing.
    python-freezegun                # Freeze time in Python tests.
    python-gevent                   # Coroutine-based networking.
    python-geoip2                   # GeoIP database lookups.
    python-google-auth              # Google API authentication.
    python-jinja                    # Jinja template rendering.
    python-ldap                     # LDAP directory access.
    python-lxml                     # XML and HTML parsing.
    python-lxml-html-clean          # HTML cleaning for lxml.
    python-magic                    # File type detection via libmagic.
    python-numpy                    # Numerical array operations.
    python-odfpy                    # OpenDocument file processing.
    python-openpyxl                 # Excel XLSX file processing.
    python-pandas                   # Tabular data analysis.
    python-paramiko                 # SSH client library.
    python-passlib                  # Password hashing helpers.
    python-pdfminer                 # PDF text extraction.
    python-phonenumbers             # Phone number parsing and validation.
    python-pillow                   # Image processing.
    python-pip                      # Python package installer.
    python-polib                    # Gettext PO file processing.
    python-psutil                   # Process and system statistics.
    python-psycopg2                 # PostgreSQL adapter for Python.
    python-pydot                    # Graphviz DOT graph generation.
    python-pyopenssl                # OpenSSL bindings for Python.
    python-pypdf2                   # PDF reading and manipulation.
    python-qrcode                   # QR code generation.
    python-reportlab                # PDF generation.
    python-requests                 # HTTP client for Python.
    python-rjsmin                   # JavaScript minification.
    python-pytz                     # Time zone definitions for Python.
    python-setuptools               # Python package build tools.
    python-slugify                  # URL-friendly text slugs.
    python-vobject                  # vCard and vCalendar parsing.
    python-watchdog                 # Filesystem event monitoring.
    python-werkzeug                 # WSGI and web utilities.
    python-wheel                    # Python wheel package format.
    python-xlrd                     # Read legacy Excel XLS files.
    python-xlwt                     # Write legacy Excel XLS files.
    python-xmltodict                # XML-to-dictionary conversion.
    python-xmlsec                   # XML signatures and encryption.
    python-xlsxwriter               # Excel XLSX file generation.
    python-zeep                     # SOAP web service client.
    powertop                        # Power-consumption diagnostics.
    networkmanager                  # Network connection manager.
    network-manager-applet          # NetworkManager tray applet.
    networkmanager-openconnect      # OpenConnect NetworkManager plugin.
    networkmanager-openvpn          # OpenVPN NetworkManager plugin.
    networkmanager-pptp             # PPTP NetworkManager plugin.
    networkmanager-vpnc             # VPNC NetworkManager plugin.
    nm-connection-editor            # NetworkManager connection editor.
    arandr                          # Display-layout configuration UI.
    intel-media-driver              # Intel VA-API driver for hardware video decode and encode.
    vulkan-intel                    # Intel Vulkan driver.
    vulkan-tools
    libva-utils                     # VA-API diagnostics such as vainfo.
    intel-gpu-tools                 # Intel GPU monitoring such as intel_gpu_top.
    laptop-detect                   # Detect laptop hardware.
    lxappearance                    # GTK theme configuration UI.
    upower                          # Battery and power information service.
    vscodium                        # Code editor (telemetry-free VS Code build).
    vlc                             # Media player.
    sshfs                           # Mount filesystems over SSH.
    sshpass                         # Non-interactive SSH password input.
    sshuttle                        # VPN-like SSH tunnel.
    stunnel                         # TLS tunnels for remote Bitcoin and Knots RPC.
    wireplumber                     # PipeWire policy and session manager.
    xarchiver                       # Archive manager UI.
    xclip                           # X11 clipboard command-line tool.
    xdg-user-dirs                   # Standard user-directory management.
    xmlsec                          # XML encryption and signature tooling.
    yt-dlp                          # Video downloader.
    zbar                            # Barcode and QR-code reader.
    zoom                            # Video-conferencing client.
    ttf-caladea                     # Cambria-compatible font.
    texlive-basic                   # LaTeX document toolchain.
    texlive-latex                   # Core LaTeX macros and packages.
    texlive-binextra                # Auxiliary TeX programs.
    texlive-latexrecommended        # Common LaTeX extensions.
    texlive-fontsrecommended        # Common TeX font collections.
    texlive-fontsextra              # Additional TeX fonts.
    texlive-xetex                   # XeTeX engine and support files.
    texlive-luatex                  # LuaTeX engine and support files.
    texlive-latexextra              # Additional LaTeX packages.
    texlive-pictures                # Graphics and diagram packages.
    texlive-bibtexextra             # Extra BibTeX styles.
    ttf-carlito                     # Calibri-compatible font.
    ttf-droid                       # Android Droid font family.
    inter-font                      # Awesome window-manager UI font.
    noto-fonts                      # Broad Unicode font coverage.
    noto-fonts-emoji                # Emoji font support.
    discord                         # Discord desktop client.
    dunst                           # Lightweight notification daemon.
    dconf                           # GTK settings database.
    feh                             # Lightweight image viewer.
    ufw                             # Firewall
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

if [[ ! -f /etc/pacman.d/chaotic-mirrorlist ]]; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
fi

sudo install -D -o root -g root -m 644 "$HOME/.config/install/pacman.conf" /etc/pacman.conf

sudo reflector --latest 5 --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syy --noconfirm --needed "${laptop_packages[@]}"
makepkg -D "$HOME/.local/share/pkgbuilds/archlinux-logout" --force --clean --syncdeps --install --noconfirm
makepkg -D "$HOME/.local/share/pkgbuilds/wkhtmltopdf-bin" --force --clean --syncdeps --install --noconfirm
makepkg -D "$HOME/.local/share/pkgbuilds/python310-bin" --force --clean --syncdeps --install --noconfirm

sudo install -D -o root -g root -m 644 "$HOME/.config/install/10-bluetooth.conf" /etc/tlp.d/10-bluetooth.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/10-battery.conf" /etc/tlp.d/10-battery.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/btusb.conf" /etc/modprobe.d/btusb.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/backlight.rules" /etc/udev/rules.d/backlight.rules
sudo install -D -o root -g root -m 644 "$HOME/.config/install/hosts" /etc/hosts
sudo install -D -o root -g root -m 644 "$HOME/.config/install/stunnel.conf" /etc/stunnel/stunnel.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/environment" /etc/environment
sudo install -D -o root -g root -m 644 "$HOME/.config/install/UPower.conf" /etc/UPower/UPower.conf
sudo install -D -o root -g root -m 755 "$HOME/.config/install/x-monitor-layout" /usr/local/bin/x-monitor-layout
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sddm.conf" /etc/sddm.conf.d/sddm.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sddm-hyprland.lua" /etc/sddm/hyprland.lua
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sddm-theme/Main.qml" /usr/share/sddm/themes/nocturne/Main.qml
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sddm-theme/metadata.desktop" /usr/share/sddm/themes/nocturne/metadata.desktop
sudo install -D -o root -g root -m 644 "$HOME/.config/install/awesome-portals.conf" /etc/xdg-desktop-portal/awesome-portals.conf
sudo install -D -o root -g root -m 644 "$HOME/.config/install/dconf/profile/user" /etc/dconf/profile/user
sudo install -D -o root -g root -m 644 "$HOME/.config/install/dconf/local.d/00-settings" /etc/dconf/db/local.d/00-settings
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sudo" /etc/pam.d/sudo
sudo install -D -o root -g root -m 644 "$HOME/.config/install/polkit-1" /etc/pam.d/polkit-1
sudo install -D -o root -g root -m 644 "$HOME/.config/install/i3lock" /etc/pam.d/i3lock
sudo install -D -o root -g root -m 755 "$HOME/.config/install/lxlock" /usr/local/bin/lxlock
sudo install -D -o root -g root -m 644 "$HOME/.config/install/ssh-agent-fprint-askpass.conf" /etc/systemd/user/ssh-agent.service.d/fprint-askpass.conf
sudo install -D -o root -g root -m 755 "$HOME/.config/install/ssh-askpass-fprint" /usr/local/bin/ssh-askpass-fprint
sudo install -D -o root -g root -m 755 "$HOME/.config/install/sddm-fingerprint-selected" /usr/local/bin/sddm-fingerprint-selected
sudo install -D -o root -g root -m 644 "$HOME/.config/install/sddm" /etc/pam.d/sddm
sudo install -D -o root -g root -m 755 "$HOME/.config/install/portable4t-syncthing-hook" /usr/local/bin/portable4t-syncthing-hook
sudo install -D -o root -g root -m 644 "$HOME/.config/install/portable4t-udisks-events.service" /etc/systemd/system/portable4t-udisks-events.service

sudo dconf update
sudo mkinitcpio -P
sudo udevadm control --reload-rules
sudo systemctl daemon-reload

# IPv6 local discovery is link-local multicast, not traffic from the IPv4 LAN:
# fe80::/10 matches auto-assigned, same-link-only IPv6 source addresses (the
# individual fe80:: address varies per device/network); ff12::8384 is
# Syncthing's fixed local-discovery multicast group. Neither is reachable
# from the Internet.
sudo ufw allow in from fe80::/10 to ff12::8384 port 21027 proto udp
sudo ufw allow from 192.168.1.0/24 to any app syncthing
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# https://github.com/systemd/systemd/issues/43848
sudo systemctl mask systemd-tpm2-setup-early.service systemd-pcrproduct.service systemd-pcrlogin@.service

sudo systemctl enable cronie NetworkManager bluetooth stunnel tlp upower sddm ufw reflector.timer
sudo systemctl enable --now portable4t-udisks-events.service
systemctl --user enable ssh-agent.service
systemctl --user daemon-reload
