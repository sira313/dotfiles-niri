#!/usr/bin/env bash
# ~/.config/waybar/scripts/tuned-profile.sh
# Ganti profil tuned via D-Bus — tidak perlu sudo/pkexec

PROFILES=("powersave" "balanced" "throughput-performance")

get_class() {
  case "$1" in
    *powersave*)            echo "powersave" ;;
    *balanced*)             echo "balanced" ;;
    *perform*|*throughput*) echo "performance" ;;
    *)                      echo "balanced" ;;
  esac
}

case "$1" in
  get)
    raw=$(tuned-adm active 2>/dev/null | awk -F': ' '{print $2}' | tr -d '[:space:]')
    class=$(get_class "$raw")
    printf '{"text":"","alt":"%s","tooltip":"Profile: %s","class":"%s"}\n' \
      "$class" "${raw:-unknown}" "$class"
    ;;

  toggle)
    raw=$(tuned-adm active 2>/dev/null | awk -F': ' '{print $2}' | tr -d '[:space:]')
    idx=0
    for i in "${!PROFILES[@]}"; do
      [[ "${PROFILES[$i]}" == "$raw" ]] && idx=$i && break
    done
    next=$(( (idx + 1) % ${#PROFILES[@]} ))
    next_profile="${PROFILES[$next]}"

    # Coba via D-Bus dulu (tidak butuh sudo)
    busctl call com.redhat.tuned /Tuned com.redhat.tuned.control \
      switch_profile s "$next_profile" 2>/dev/null \
    || sudo tuned-adm profile "$next_profile"
    ;;
esac
