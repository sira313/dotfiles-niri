#!/usr/bin/env bash
# ~/.config/waybar/scripts/cellular.sh
# Ikon sinyal WWAN (ModemManager) untuk Waybar.

MODEM_ID="${MODEM_ID:-}"
if [[ -z "$MODEM_ID" ]]; then
  MODEM_ID="$(mmcli -L 2>/dev/null | sed -n 's|.*Modem/\([0-9]\+\).*|\1|p' | head -n1)"
fi

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

emit() {
  local text="$1" alt="$2" tooltip="$3" class="$4"
  printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' \
    "$text" "$alt" "$(json_escape "$tooltip")" "$class"
}

if ! command -v mmcli >/dev/null 2>&1 || [[ -z "$MODEM_ID" ]]; then
  emit "󰞃" "off" "WWAN: modem tidak terdeteksi" "off"
  exit 0
fi

info="$(mmcli -m "$MODEM_ID" -K 2>/dev/null)" || info=""
get() {
  awk -F' *: *' -v key="$1" '$1 == key { print $2; exit }' <<<"$info"
}

state="$(get 'modem.generic.state')"
quality="$(get 'modem.generic.signal-quality.value')"
operator="$(get 'modem.3gpp.operator-name')"
regstate="$(get 'modem.3gpp.registration-state')"
packet="$(get 'modem.3gpp.packet-service-state')"
tech="$(get 'modem.generic.access-technologies.value[1]')"
ipaddr="$(ip -4 -br addr show wwan0 2>/dev/null | awk '{print $3; exit}')"

[[ "$quality" =~ ^[0-9]+$ ]] || quality=0
[[ -n "$state" && "$state" != "--" ]] || state="unknown"
[[ -n "$operator" && "$operator" != "--" ]] || operator="tanpa operator"
[[ -n "$regstate" && "$regstate" != "--" ]] || regstate="unknown"
[[ -n "$packet" && "$packet" != "--" ]] || packet="unknown"
[[ -n "$tech" && "$tech" != "--" ]] || tech="?"
upper_tech="$(tr '[:lower:]' '[:upper:]' <<<"$tech")"

# Data dianggap aktif hanya kalau modem attached + NetworkManager sudah
# memberi IP. Tanpa ini, `nmcli connection down` tidak mengubah icon.
data_up=0
[[ "$state" == "connected" && "$packet" == "attached" && -n "$ipaddr" ]] && data_up=1

if (( quality >= 75 )); then
  icon="󰢿"
elif (( quality >= 50 )); then
  icon="󰢼"
elif (( quality >= 25 )); then
  icon="󰢽"
else
  icon="󰢾"
fi

if (( data_up )); then
  text="$icon"
  class="connected"
  # Hotspot active → same colour as clock (handled by CSS class).
  if nmcli -t -f NAME con show --active 2>/dev/null | grep -qx 'hotspot'; then
    class="hotspot"
  fi
else
  icon="󰞃"
  case "$state" in
    disabled)                         class="off"  ;;
    registered|enabled|connecting|connected) class="idle" ;;
    *)                                class="off"  ;;
  esac
  text="$icon"
fi

tooltip="WWAN · ${upper_tech} · sinyal ${quality}%"
tooltip+=$'\r'"${operator} · ${regstate} · ${packet}"
[[ -n "$ipaddr" ]] && tooltip+=$'\r'"wwan0 ${ipaddr}"

emit "$text" "$tech" "$tooltip" "$class"
