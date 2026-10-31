function hotspot-off --description 'Stop WiFi hotspot started by hotspot'
    set -l con hotspot

    if not nmcli -t -f NAME con show --active | string match -q -- $con
        echo "Hotspot tidak aktif."
        return 0
    end

    if nmcli con down $con
        notify-send 'Hotspot' 'Dimatikan' -i network-offline
        echo "Hotspot dimatikan."
    else
        echo "Gagal mematikan hotspot."
        return 1
    end
end
