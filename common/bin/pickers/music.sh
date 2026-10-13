#!/usr/bin/env bash
# Port a bash de https://github.com/Marco98/rofi-mpc usando core.sh
# Motor: PICKER_ENGINE=rofi|tofi|noctalia (ver core.sh)

source "$HOME/bin/pickers/dependencies/core.sh"

# ---------- Etiquetas (Nerd Font) ----------
TOGGLE=$'\U000f040e Play/Pause'
NEXT=$'\U000f04ad Next'
PREV=$'\U000f04ae Prev'
STOP=$'\U000f06c9 Clear'
LIST=$'\uf03a List'

OPT_ALBUMS=$'\ue78c Albums'
OPT_ARTISTS=$'\U000f0009 Artists'
OPT_PLAYLISTS=$'\U000f0411 Playlists'
OPT_ALL_SONGS=$'\uf001 All Songs'
OPT_PLAY_ALL="[Play All]"

# ---------- Helpers ----------
# menu "prompt" "mesg" [selected_row]   (opciones por stdin)
menu() {
  local prompt="$1" mesg="$2" row="$3"
  local args=()
  [[ -n "$row" ]] && args+=(-selected-row "$row")
  rofi_core -p "$prompt" -mesg "$mesg" -- "${args[@]}"
}

escape_markup() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  printf '%s' "$s"
}

playlist_len() { mpc playlist | wc -l; }

# notification "titulo" "cuerpo" [icono]
notification() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -r 99 -t 1500 -u low "$1" "$2" -i "${3:-multimedia-player}"
}

# Notifica la pista actual, con título opcional ("Playing" por defecto)
notify_track() {
  local t
  t=$(mpc -f '[%artist% - ]%title%' current)
  notification "${1:-Playing}" "$(escape_markup "${t:-Nothing playing}")" \
    "${2:-media-playback-start}"
}

# Lee el estado actual (tras cambiarlo) desde mpc
mpc_flag() { mpc | grep -o "$1: [a-z]*" | head -n1 | cut -d' ' -f2; }

repeat_label() {
  if [[ "$(mpc_flag repeat)" != on ]]; then
    echo Off
  elif [[ "$(mpc_flag single)" == off ]]; then
    echo On
  else
    echo Single
  fi
}

play_last_added() { mpc play "$(playlist_len)"; }

show_sources() {
  local sel chosen files
  sel=$(printf '%s\n' "$OPT_PLAYLISTS" "$OPT_ALBUMS" "$OPT_ARTISTS" "$OPT_ALL_SONGS" |
    menu "Search by: " "$current_track")
  [[ -z "$sel" ]] && exit 0

  case "$sel" in
  "$OPT_ALBUMS")
    chosen=$(mpc list album | menu "Choose Album: " "")
    if [[ -n "$chosen" ]]; then
      mpc findadd album "$chosen" && mpc play >/dev/null
    fi
    ;;
  "$OPT_ARTISTS")
    chosen=$(mpc list artist | menu "Choose Artist: " "")
    if [[ -n "$chosen" ]]; then
      mpc findadd artist "$chosen" && mpc play >/dev/null
    fi
    ;;
  "$OPT_ALL_SONGS")
    files=$(mpc listall)
    chosen=$({
      printf '%s\n' "$OPT_PLAY_ALL"
      printf '%s\n' "$files"
    } |
      menu "Search Song: " "")
    if [[ "$chosen" == "$OPT_PLAY_ALL" ]]; then
      mpc update
      printf '%s\n' "$files" | mpc add
      mpc play >/dev/null
    elif [[ -n "$chosen" ]]; then
      mpc add "$chosen"
      play_last_added >/dev/null
    fi
    ;;
  "$OPT_PLAYLISTS")
    chosen=$(mpc lsplaylists | grep -v -e '^[[:space:]]*$' -e '^tmp\.m3u$' |
      menu "Playlist: " "")
    if [[ -n "$chosen" ]]; then
      mpc load "${chosen%.m3u}" && mpc play >/dev/null
    fi
    ;;
  esac
}

show_track_list() {
  local n=0 line list="" sel
  while IFS= read -r line; do
    ((n++))
    list+="[$n] $line"$'\n'
  done < <(mpc playlist)

  if ((n > 1)); then
    list="[SOURCES]"$'\n'"${list%$'\n'}"
    sel=$(printf '%s\n' "$list" | menu "Play: " "" 0)
    [[ -z "$sel" ]] && exit 0
    sel="${sel#*\[}"
    sel="${sel%%\]*}"
  else
    sel="SOURCES"
  fi

  if [[ "$sel" == "SOURCES" ]]; then
    show_sources
  else
    mpc play "$sel" >/dev/null
  fi
}

# ---------- Estado ----------
status_output=$(mpc)
current_title=$(mpc -f '%title%' current)

if [[ -z "$current_title" ]]; then
  current_track="Nothing is currently playing"
elif [[ "$status_output" == *paused* ]]; then
  current_track="Paused: $(escape_markup "$current_title")"
else
  current_track="Currently Playing: $(escape_markup "$current_title")"
fi

onoff() { [[ "$status_output" == *"$1: on"* ]] && echo On || echo Off; }
RANDOM_OPT=$'\U000f049d Random: '"$(onoff random)"

# Repeat cicla: Off -> On -> Single (repeat + single) -> Off
if [[ "$status_output" != *"repeat: on"* ]]; then
  repeat_state=off
  REPEAT_LABEL=Off
elif [[ "$status_output" == *"single: off"* ]]; then
  repeat_state=on
  REPEAT_LABEL=On
else
  repeat_state=single
  REPEAT_LABEL=Single
fi
REPEAT_OPT=$'\U000f0456 Repeat: '"$REPEAT_LABEL"
CONSUME_OPT=$'\U000f10d8 Consume: '"$(onoff consume)"

# ---------- Menú principal ----------
if [[ "$(playlist_len)" -eq 0 ]]; then
  show_sources
  exit 0
fi

selection=$(printf '%s\n' \
  "$LIST" "$TOGGLE" "$NEXT" "$PREV" "$STOP" \
  "$REPEAT_OPT" "$RANDOM_OPT" "$CONSUME_OPT" \
  "Volume 25%" "Volume 50%" "Volume 75%" "Volume 100%" |
  menu "Select: " "$current_track" 1)

case "$selection" in
"$TOGGLE")
  mpc toggle >/dev/null
  if [[ "$(mpc)" == *"[playing]"* ]]; then
    notify_track "Playing"
  else
    notify_track "Paused" media-playback-pause
  fi
  ;;
"$NEXT")
  mpc next >/dev/null
  ;;
"$PREV")
  mpc prev >/dev/null
  ;;
"$STOP")
  mpc stop >/dev/null && mpc clear >/dev/null
  ;;
"$RANDOM_OPT")
  mpc random >/dev/null
  notification "Random" "$(mpc_flag random)" media-playlist-shuffle
  ;;
"$REPEAT_OPT")
  case "$repeat_state" in
  off) mpc single off >/dev/null && mpc repeat on >/dev/null ;;
  on) mpc single on >/dev/null ;;
  single) mpc single off >/dev/null && mpc repeat off >/dev/null ;;
  esac
  notification "Repeat" "$(repeat_label)" media-playlist-repeat
  ;;
"$CONSUME_OPT")
  mpc consume >/dev/null
  notification "Consume" "$(mpc_flag consume)" media-playlist-consume
  ;;
"$LIST") show_track_list ;;
Volume\ *)
  vol="${selection#Volume }"
  mpc volume "${vol%\%}" >/dev/null
  ;;
esac
