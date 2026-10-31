function hotspot --description 'Start WiFi hotspot (AP mode) sharing current uplink'
    set -l con hotspot

    # Already running?
    if nmcli -t -f NAME con show --active | string match -q -- $con
        echo "Hotspot sudah aktif:"
        nmcli -t -f NAME,DEVICE con show --active | string match -- "$con:*"
        echo "Matikan dengan: hotspot-off"
        return 0
    end

    # Shared mode needs dnsmasq as DHCP server for clients.
    if not command -q dnsmasq
        echo "dnsmasq belum terpasang. Hotspot butuh dnsmasq sebagai DHCP server."
        read -l -P "Install dnsmasq sekarang? [Y/n]: " yn
        if test -n "$yn"; and not string match -qi y -- $yn
            echo "Dibatalkan. Jalankan: sudo pacman -S dnsmasq"
            return 1
        end
        sudo pacman -S --needed --noconfirm dnsmasq; or return 1
    end

    set -l dev (nmcli -t -f DEVICE,TYPE dev status | awk -F: '$2=="wifi"{print $1; exit}')
    if test -z "$dev"
        echo "Tidak ada device wifi."
        return 1
    end

    nmcli radio wifi on

    # Defaults from saved connection, so re-run is one command.
    set -l cur_ssid
    set -l cur_psk
    if nmcli -t -f NAME con show | string match -q -- $con
        set cur_ssid (nmcli -s -g 802-11-wireless.ssid con show $con 2>/dev/null)
        set cur_psk (nmcli -s -g 802-11-wireless-security.psk con show $con 2>/dev/null)
    end

    set -l def_ssid ArisHotspot
    test -n "$cur_ssid"; and set def_ssid $cur_ssid
    read -l -P "SSID [$def_ssid]: " ssid
    test -z "$ssid"; and set ssid $def_ssid

    set -l psk
    while true
        read -P "Password WPA2 (8-63 char): " psk
        or return 1
        if test -z "$psk"
            if test -n "$cur_psk"
                set psk $cur_psk
                break
            end
            echo "Password tidak boleh kosong."
            continue
        end
        set -l len (string length -- "$psk")
        if test $len -ge 8; and test $len -le 63
            break
        end
        echo "Password harus 8-63 karakter."
    end

    if nmcli -t -f NAME con show | string match -q -- $con
        nmcli con mod $con ssid "$ssid" wifi-sec.psk "$psk"; or return 1
    else
        nmcli con add type wifi ifname $dev con-name $con \
            ssid "$ssid" 802-11-wireless.mode ap 802-11-wireless.band bg \
            ipv4.method shared ipv6.method ignore \
            wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$psk"; or return 1
    end

    # Shared mode needs kernel IPv4 forwarding. NM 1.58 does not set it.
    if test (sysctl -n net.ipv4.ip_forward 2>/dev/null) != 1
        echo "Mengaktifkan IPv4 forwarding..."
        sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null; or return 1
    end

    echo "Mengaktifkan hotspot di $dev..."
    if not nmcli con up $con
        echo "Gagal mengaktifkan hotspot. Log terakhir:"
        journalctl -u NetworkManager -n 15 --no-pager -o cat | string match -i '*wlp*'
        return 1
    end

    notify-send 'Hotspot' "Aktif: $ssid" -i network-wireless
    echo "Hotspot aktif."
    echo "  SSID     : $ssid"
    echo "  Gateway  : 10.42.0.1"
    echo "  Uplink   : "(ip route show default | string replace -r '.*dev (\S+).*' '$1')
    echo "  Matikan  : hotspot-off"
end
