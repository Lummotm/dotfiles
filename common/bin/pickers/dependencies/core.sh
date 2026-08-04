#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/default.rasi"
TOFI_CONFIG_DEFAULT="$HOME/.config/tofi/config"

# Permite forzar el engine globalmente para testear en bloque:
#   ROFI_ENGINE=tofi ./rofi-audio.sh
# o por script suelto pasando --tofi a rofi_core.
ROFI_ENGINE="${ROFI_ENGINE:-rofi}"

rofi_core() {
  local width="60ch"
  local prompt=""
  local show_icons="false"
  local mode="dmenu"
  local extra_css=""
  local hide_inputbar="false"
  local mesg=""
  local password="false"
  local rofi_args=()
  local engine="$ROFI_ENGINE"

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -w | --width)
      width="$2"
      shift 2
      ;;
    -p | --prompt)
      prompt="$2"
      shift 2
      ;;
    -i | --icons)
      show_icons="true"
      shift 1
      ;;
    -m | --mode)
      mode="$2"
      shift 2
      ;;
    -c | --css)
      extra_css="$2"
      shift 2
      ;;
    -N | --no-input)
      hide_inputbar="true"
      shift 1
      ;;
    -mesg)
      mesg="$2"
      shift 2
      ;;
    -password)
      password="true"
      shift 1
      ;;
    --tofi)
      engine="tofi"
      shift 1
      ;;
    --rofi)
      engine="rofi"
      shift 1
      ;;
    --)
      shift
      rofi_args+=("$@")
      break
      ;;
    *)
      rofi_args+=("$1")
      shift 1
      ;;
    esac
  done

  if [[ "$engine" == "tofi" ]]; then
    _tofi_run "$width" "$prompt" "$mode" "$mesg" "$password" "$hide_inputbar" "${rofi_args[@]}"
  else
    _rofi_run "$width" "$prompt" "$show_icons" "$mode" "$extra_css" "$hide_inputbar" "$mesg" "$password" "${rofi_args[@]}"
  fi
}

_rofi_run() {
  local width="$1" prompt="$2" show_icons="$3" mode="$4" extra_css="$5" hide_inputbar="$6" mesg="$7" password="$8"
  shift 8
  local rofi_args=("$@")

  local theme_str="window { width: $width; }"

  if [[ "$hide_inputbar" == "true" ]]; then
    theme_str+=" inputbar { enabled: false; }"
  elif [[ -n "$prompt" ]]; then
    theme_str+=" prompt { enabled: true; } textbox-prompt-colon { enabled: true;  } entry { cursor-width: 1px; }"
  fi

  if [[ "$show_icons" == "true" ]]; then
    theme_str+=" configuration { show-icons: true; } element-icon { enabled: true; margin: 0 10px 0 0; }"
  fi

  if [[ -n "$extra_css" ]]; then
    theme_str+=" $extra_css"
  fi

  local cmd=(rofi -theme "$ROFI_THEME" -theme-str "$theme_str" -i)

  if [[ "$mode" == "dmenu" ]]; then
    cmd+=(-dmenu)
  else
    cmd+=(-show "$mode")
  fi

  [[ -n "$prompt" ]] && cmd+=(-p "$prompt")
  [[ -n "$mesg" ]] && cmd+=(-mesg "$mesg")
  [[ "$password" == "true" ]] && cmd+=(-password)

  "${cmd[@]}" "${rofi_args[@]}"
}

_tofi_run() {
  local width="$1" prompt="$2" mode="$3" mesg="$4" password="$5" hide_inputbar="$6"
  shift 6
  local rofi_args=("$@")

  if [[ "$mode" != "dmenu" ]]; then
    echo "[rofi-core:tofi] '-m $mode' no soportado en tofi (no hay modos/plugins). Abortando." >&2
    return 1
  fi

  local cmd=(tofi)

  [[ -f "$TOFI_CONFIG_DEFAULT" ]] && cmd+=(--config "$TOFI_CONFIG_DEFAULT")
  [[ -n "$prompt" && "$hide_inputbar" != "true" ]] && cmd+=(--prompt-text "$prompt")
  [[ "$password" == "true" ]] && cmd+=(--hide-input true)

  if [[ -n "$width" ]]; then
    echo "[rofi-core:tofi] aviso: -w '$width' ignorado, manda el width del config de tofi" >&2
  fi
  if [[ -n "$mesg" ]]; then
    echo "[rofi-core:tofi] aviso: -mesg ignorado ('$mesg')" >&2
  fi
  # Avisa si detecta flags de rofi crudos que no tienen sentido en tofi
  for arg in "${rofi_args[@]}"; do
    case "$arg" in
    -a | -kb-custom-* | -kb-accept-alt | -markup-rows | -no-custom | -sort)
      echo "[rofi-core:tofi] aviso: flag '$arg' no soportado en tofi, ignorado" >&2
      ;;
    esac
  done

  "${cmd[@]}"
}
