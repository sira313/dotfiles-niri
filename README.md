![ss](https://raw.githubusercontent.com/sira313/dotfiles-niri/refs/heads/main/Screenshots/ss.png)
# Arch + Niri + Waybar
After install minimal Arch Linux with archinstall

### Setup home dir
```
sudo pacman -S xdg-user-dirs && xdg-user-dirs-update
```

### Install Paru
```
sudo pacman -S --needed base-devel git
```
```
git clone https://aur.archlinux.org/paru.git && cd paru
```
```
makepkg -si
```
### Install Prerequisites
```
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
  ryzenadj \
```
Note: Ryzenadj is optional

### Config
Copy All dir & file exactly the same path

## Tips 
###
Open xorg based apps we must install this
```
sudo pacman -S xwayland-satellite
```
### Samba
```
nano /etc/samba/smb.conf
```
Put this config
```
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
Add user
```
sudo smbpasswd -a YourUsername
```
Activate user
```
sudo smbpasswd -e YourUsername
```
Allow port
```
sudo ufw allow 137,138/udp
sudo ufw allow 139,445/tcp
sudo ufw reload
```
Share Public dir
```
share-on
```
Stop share Public dir
```
share-off
```

### Windows
Copy windows11.iso to `~/Documents/iso`
```
cd Documents/windows11/ && podman-compose up -d && podman-compose logs -f
```
Wait installation finish, debloat it!!!

#### Shortcut
Press `meta` + `space` search `Start Win` to start windows and freerdp. Use `Stop Win` to stop the service.

### Important shortcut
`Meta + T` Kitty

`Meta + E` Nautilus

`Meta + Space` App launcher

`Meta + Shift + /` Shortcut list

`Meta + x` Power menu
