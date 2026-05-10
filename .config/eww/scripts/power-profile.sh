#!/usr/bin/env bash

PROFILES=(
  "powersave"
  "balanced"
  "throughput-performance"
)

get_class() {
  case "$1" in
    *powersave*)
      echo "powersave"
      ;;

    *balanced*)
      echo "balanced"
      ;;

    *perform*|*throughput*)
      echo "performance"
      ;;

    *)
      echo "balanced"
      ;;
  esac
}


get_current() {
  raw=$(tuned-adm active 2>/dev/null \
    | awk -F': ' '{print $2}' \
    | tr -d '[:space:]')

  get_class "$raw"
}


toggle_profile() {
  raw=$(tuned-adm active 2>/dev/null \
    | awk -F': ' '{print $2}' \
    | tr -d '[:space:]')

  idx=0

  for i in "${!PROFILES[@]}"; do
    if [[ "${PROFILES[$i]}" == "$raw" ]]; then
      idx=$i
      break
    fi
  done

  next=$(( (idx + 1) % ${#PROFILES[@]} ))
  next_profile="${PROFILES[$next]}"

  busctl call \
    com.redhat.tuned \
    /Tuned \
    com.redhat.tuned.control \
    switch_profile s "$next_profile" \
    2>/dev/null \
  || tuned-adm profile "$next_profile" >/dev/null 2>&1
}


set_profile() {
  profile="$1"

  busctl call \
    com.redhat.tuned \
    /Tuned \
    com.redhat.tuned.control \
    switch_profile s "$profile" \
    2>/dev/null \
  || tuned-adm profile "$profile" >/dev/null 2>&1
}


case "$1" in
  get)
    get_current
    ;;

  toggle)
    toggle_profile
    ;;

  set)
    set_profile "$2"
    ;;

  *)
    get_current
    ;;
esac