# DNAT rules live in memory only (iptables not persistent), so add/remove with the hotspot.
function __hotspot_dns_rules --argument-names action dev
    for proto in udp tcp
        if test $action = add
            sudo iptables -t nat -C PREROUTING -i $dev -p $proto --dport 53 -j DNAT --to-destination 8.8.8.8:53 2>/dev/null
            or sudo iptables -t nat -A PREROUTING -i $dev -p $proto --dport 53 -j DNAT --to-destination 8.8.8.8:53
        else
            sudo iptables -t nat -D PREROUTING -i $dev -p $proto --dport 53 -j DNAT --to-destination 8.8.8.8:53 2>/dev/null
        end
    end
end

function hotspot --description 'Start/stop WiFi hotspot (AP mode) sharing current uplink'
    set -l con hotspot

    if contains -- --off $argv
        if not nmcli -t -f NAME con show --active | string match -q -- $con
            echo "Hotspot tidak aktif."
            return 0
        end
        set -l offdev (nmcli -s -g connection.interface-name con show $con 2>/dev/null)
        test -n "$offdev"; and __hotspot_dns_rules del $offdev
        if nmcli con down $con
            notify-send 'Hotspot' 'Dimatikan' -i network-offline
            echo "Hotspot dimatikan."
            return 0
        end
        echo "Gagal mematikan hotspot."
        return 1
    end

    # Already running?
    if nmcli -t -f NAME con show --active | string match -q -- $con
        echo "Hotspot sudah aktif:"
        nmcli -t -f NAME,DEVICE con show --active | string match -- "$con:*"
        echo "SSID     : "(nmcli -s -g 802-11-wireless.ssid con show $con 2>/dev/null)
        echo "Password : "(nmcli -s -g 802-11-wireless-security.psk con show $con 2>/dev/null)
        echo "Matikan dengan: hotspot --off"
        nmcli con mod $con connection.autoconnect no
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

    # Reuse saved connection silently; only prompt on first run or --setup.
    if nmcli -t -f NAME con show | string match -q -- $con; and not contains -- --setup $argv
        set ssid (nmcli -s -g 802-11-wireless.ssid con show $con 2>/dev/null)
    else
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
            nmcli con mod $con ssid "$ssid" wifi-sec.psk "$psk" connection.autoconnect no; or return 1
        else
            nmcli con add type wifi ifname $dev con-name $con \
                ssid "$ssid" 802-11-wireless.mode ap 802-11-wireless.band bg \
                ipv4.method shared ipv6.method ignore connection.autoconnect no \
                wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$psk"; or return 1
        end
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

    # iptables rules vanish on reboot; re-add them every time the hotspot comes up.
    __hotspot_dns_rules add $dev

    notify-send 'Hotspot' "Aktif: $ssid" -i network-wireless
    echo "Hotspot aktif."
    echo "  SSID     : $ssid"
    echo "  Password : "(nmcli -s -g 802-11-wireless-security.psk con show $con 2>/dev/null)
    echo "  Gateway  : 10.42.0.1"
    echo "  Uplink   : "(ip route show default | string replace -r '.*dev (\S+).*' '$1')
    echo "  Matikan  : hotspot --off"
    echo "  Ubah     : hotspot --setup"
end
