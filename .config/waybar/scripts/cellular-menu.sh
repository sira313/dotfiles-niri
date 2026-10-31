#!/usr/bin/env bash
# ~/.config/waybar/scripts/cellular-menu.sh
# Menu interaktif WWAN. Memakai CLI project xmm7360-wwan tanpa mengubahnya.
set -uo pipefail

PROJECT="${WWAN_PROJECT:-$HOME/Documents/Projects/xmm7360-wwan}"
WWAN="$PROJECT/scripts/wwan"
CONFIG="$PROJECT/config.env"
[[ -f "$CONFIG" ]] || CONFIG="$PROJECT/config.env.example"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
pause() { read -rp $'\nTekan Enter untuk kembali...' _; }

cfg() {
  [[ -f "$CONFIG" ]] || return 0
  awk -F= -v key="$1" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$CONFIG"
}

modem_id() {
  mmcli -L 2>/dev/null | sed -n 's|.*Modem/\([0-9]\+\).*|\1|p' | head -n1
}

mmval() {
  local id="$1" key="$2"
  mmcli -m "$id" -K 2>/dev/null \
    | awk -F' *: *' -v k="$key" '$1 == k { print $2; exit }'
}

header() {
  clear
  printf '╔══════════════════════════════════════════════════╗\n'
  printf '║  WWAN · Intel XMM7360 / Fibocom L850-GL          ║\n'
  printf '╚══════════════════════════════════════════════════╝\n'
  local id state op q reg
  id="$(modem_id)"
  if [[ -z "$id" ]]; then
    printf '  modem : tidak terdeteksi\n\n'
    return
  fi
  state="$(mmval "$id" 'modem.generic.state')"
  op="$(mmval "$id" 'modem.3gpp.operator-name')"
  q="$(mmval "$id" 'modem.generic.signal-quality.value')"
  reg="$(mmval "$id" 'modem.3gpp.registration-state')"
  printf '  modem : %s · sinyal %s%% · reg %s\n' "${state:-?}" "${q:-?}" "${reg:-?}"
  printf '  operator: %s\n\n' "${op:-?}"
}

[[ -x "$WWAN" ]] || die "tidak menemukan $WWAN"

while true; do
  header
  cat <<'EOF'
  1) Status lengkap
  2) Connect (pakai config.env)
  3) Connect dengan APN/PIN manual
  4) Disconnect
  5) Info SIM
  6) Detail sinyal
  7) Reset modem (ACPI)
  8) Diagnostik
  q) Keluar
EOF
  read -rp $'\nPilihan: ' choice || break

  case "$choice" in
    1)
      "$WWAN" status
      pause
      ;;
    2)
      "$WWAN" up
      pause
      ;;
    3)
      apn="$(cfg APN)"; apn="${apn:-internet}"
      read -rp "APN [$apn]: " input; apn="${input:-$apn}"
      read -rp "PIN (kosongkan kalau tidak ada): " pin
      read -rp "Metric route [700]: " metric
      args=(--apn "$apn")
      [[ -n "$pin" ]] && args+=(--pin "$pin")
      [[ -n "$metric" ]] && args+=(--metric "$metric")
      "$WWAN" up "${args[@]}"
      pause
      ;;
    4)
      "$WWAN" down
      pause
      ;;
    5)
      "$WWAN" sim
      pause
      ;;
    6)
      id="$(modem_id)"
      if [[ -n "$id" ]]; then
        mmcli -m "$id" --signal-get 2>&1
      else
        printf 'modem tidak terdeteksi\n'
      fi
      pause
      ;;
    7)
      read -rp 'Reset modem sekarang? Koneksi akan terputus. [y/N]: ' ans
      if [[ "$ans" == [yY]* ]]; then
        "$WWAN" reset
      else
        printf 'batal\n'
      fi
      pause
      ;;
    8)
      "$WWAN" diag
      pause
      ;;
    q|Q)
      break
      ;;
    *) ;;
  esac
done
