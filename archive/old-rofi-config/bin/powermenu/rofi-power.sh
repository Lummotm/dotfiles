#!/usr/bin/env bash

# Current Theme
theme="$HOME/.config/rofi/bin/powermenu/powermenu.rasi"
theme_confirm="$HOME/.config/rofi/bin/powermenu/shared/confirm.rasi"

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
shutdown=''
reboot=''
softreboot=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme ${theme}
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${theme_confirm}
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    # He cambiado el orden para que tenga sentido visual, ajustalo a tu gusto
    echo -e "$suspend\n$logout\n$softreboot\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            mpc stop
            wait 1
            systemctl poweroff
        elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
        elif [[ $1 == '--soft-reboot' ]]; then # <--- Nueva lógica
            systemctl soft-reboot
        elif [[ $1 == '--suspend' ]]; then
            mpc -q pause
            amixer set Master mute
            systemctl suspend
        elif [[ $1 == '--logout' ]]; then
            if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
                openbox --exit
            elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
                bspc quit
            elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
                i3-msg exit
            elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
                qdbus org.kde.ksmserver /KSMServer logout 0 0 0
            elif pgrep -x "niri" >/dev/null; then
                pkill -f niri
            fi
        fi
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
    run_cmd --shutdown
    ;;
$reboot)
    run_cmd --reboot
    ;;
$softreboot) # <--- Ahora pasa por run_cmd para pedir confirmación
    run_cmd --soft-reboot
    ;;
$suspend)
    run_cmd --suspend
    ;;
$logout)
    run_cmd --logout
    ;;
esac
