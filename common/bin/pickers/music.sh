#!/usr/bin/env bash

# Port a bash de https://github.com/Marco98/rofi-mpc usando core.sh
# Motor: PICKER_ENGINE=rofi|tofi|noctalia (ver core.sh)

source "$HOME/bin/pickers/dependencies/core.sh"

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
      mpc findadd album "$chosen" && mpc play
    fi
    ;;
  "$OPT_ARTISTS")
    chosen=$(mpc list artist | menu "Choose Artist: " "")
    if [[ -n "$chosen" ]]; then
      mpc findadd artist "$chosen" && mpc play
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
      mpc play
    elif [[ -n "$chosen" ]]; then
      mpc add "$chosen"
      play_last_added
    fi
    ;;
  "$OPT_PLAYLISTS")
    chosen=$(mpc lsplaylists | grep -v -e '^[[:space:]]*$' -e '^tmp\.m3u$' |
      menu "Playlist: " "")
    if [[ -n "$chosen" ]]; then
      mpc load "${chosen%.m3u}" && mpc play
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
    mpc play "$sel"
  fi
}

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
REPEAT_OPT=$'\U000f0456 Repeat: '"$(onoff repeat)"
CONSUME_OPT=$'\U000f10d8 Consume: '"$(onoff consume)"

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
"$TOGGLE") mpc toggle ;;
"$NEXT") mpc next ;;
"$PREV") mpc prev ;;
"$STOP") mpc stop && mpc clear ;;
"$RANDOM_OPT") mpc random ;;
"$REPEAT_OPT") mpc repeat ;;
"$CONSUME_OPT") mpc consume ;;
"$LIST") show_track_list ;;
Volume\ *)
  vol="${selection#Volume }"
  mpc volume "${vol%\%}"
  ;;
esac
