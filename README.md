# Arch + Niri + Waybar

![screenshot](https://raw.githubusercontent.com/sira313/dotfiles-niri/refs/heads/main/Screenshots/ss.png)

## Table of Contents
- [Setup Home Directory](#setup-home-directory)
- [Install Paru](#install-paru)
- [Install Prerequisites](#install-prerequisites)
- [Configuration](#configuration)
- [Btrfs + Snapper](#btrfs--snapper)
- [Tips](#tips)
  - [Xorg-based Apps](#xorg-based-apps)
  - [Samba](#samba)
  - [Windows VM](#windows-vm)
- [Keyboard Shortcuts](#keyboard-shortcuts)

## Setup Home Directory

```bash
sudo pacman -S xdg-user-dirs && xdg-user-dirs-update
```

## Install Paru

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/paru.git && cd paru
makepkg -si
```

## Install Prerequisites

```bash
paru -S fish \
  nano btop fastfetch \
  brightnessctl \
  cliphist \
  wl-clipboard \
  niri \
  polkit-gnome \
  kitty nautilus \
  totem \
  loupe \
  wf-recorder \
  gst-plugins-good \
  gst-plugins-bad \
  gst-plugins-ugly \
  gst-libav \
  ffmpegthumbnailer \
  samba \
  freerdp \
  xwayland-satellite \
  podman-compose \
  mako \
  waybar \
  tofi \
  ttf-firacode-nerd \
  swaylock swaybg \
  bluetui nmtui \
  ryzenadj
```

> **Note:** `ryzenadj` is optional.

## Configuration

Copy all directories and files to the exact same paths as in this repo.

Don't forget to install **Starship** prompt:

```bash
curl -sS https://starship.rs/install.sh | sh
```

## Btrfs + Snapper

Install Snapper:

```bash
paru -S snapper
```

Create a manual-only config for root:

```bash
sudo snapper -c root create-config /
```

Edit `/etc/snapper/configs/root` and set:

```
TIMELINE_CREATE="no"
TIMELINE_CLEANUP="no"
```

Disable automatic snapshot timers:

```bash
sudo systemctl stop snapper-timeline.timer
sudo systemctl disable snapper-timeline.timer
sudo systemctl stop snapper-cleanup.timer
sudo systemctl disable snapper-cleanup.timer
```

### Snapshot Commands

| Command | Description |
|---------|-------------|
| `snap` | Create a snapshot |
| `snap-list` | View the snapshot list |
| `snap-del` | Delete a snapshot |

## Tips

### Xorg-based Apps

To run Xorg-based apps under Wayland, install:

```bash
sudo pacman -S xwayland-satellite
```

### Samba

Edit the Samba config:

```bash
nano /etc/samba/smb.conf
```

Add the following:

```ini
[global]
   workgroup = WORKGROUP
   server string = Arch Samba
   security = user
   map to guest = Bad User

[Public]
   path = /home/YourUsername/Public
   writable = yes
   guest ok = yes
   guest only = yes
   force user = YourUsername
```

Add and activate a Samba user:

```bash
sudo smbpasswd -a YourUsername
sudo smbpasswd -e YourUsername
```

Allow Samba through the firewall:

```bash
sudo ufw allow 137,138/udp
sudo ufw allow 139,445/tcp
sudo ufw reload
```

### Samba Commands

| Command | Description |
|---------|-------------|
| `share-on` | Share the Public directory |
| `share-off` | Stop sharing the Public directory |

### Windows VM

Copy `windows11.iso` to `~/Documents/iso`, then:

```bash
cd Documents/windows11/ && podman-compose up -d && podman-compose logs -f
```

Wait for the installation to finish, then debloat it.

To manage the Windows VM, press `Meta + Space` and search:
- **Start Win** — start Windows and FreeRDP
- **Stop Win** — stop the service

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Meta + T` | Open Kitty terminal |
| `Meta + E` | Open Nautilus file manager |
| `Meta + Space` | Open app launcher |
| `Meta + Shift + /` | View shortcut list |
| `Meta + X` | Open power menu |
| `Meta + Alt + R` | Record full screen |
| `Meta + Alt + S` | Stop screen recorder |
