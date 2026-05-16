#!/bin/sh

# Файл состояния для конкретного рабочего стола
STATE_FILE="/tmp/bspwm_zen_mode_$(bspc query -D -d)"

# Функция для восстановления окон
restore_windows() {
    if [ -f "$STATE_FILE" ]; then
        while read -r wid; do
            if bspc query -N -n "$wid" > /dev/null 2>&1; then
                bspc node "$wid" -g hidden=off
            fi
        done < "$STATE_FILE"
        rm -f "$STATE_FILE"
    fi
}

if [ -f "$STATE_FILE" ]; then
    # Если файл есть — принудительно восстанавливаем (ручной выход из Zen)
    restore_windows
    # Убиваем фоновый процесс слежки, если он еще жив
    pkill -f "bspc subscribe node_remove"
else
    # ВХОД В ZEN MODE
    CUR_WID=$(bspc query -N -n)
    [ -z "$CUR_WID" ] && exit 0

    ALL_WIDS=$(bspc query -N -d -n .window)
    > "$STATE_FILE"

    for wid in $ALL_WIDS; do
        if [ "$wid" != "$CUR_WID" ]; then
            bspc node "$wid" -g hidden=on
            echo "$wid" >> "$STATE_FILE"
        fi
    done

    # --- НОВАЯ ЧАСТЬ: СЛЕЖКА ЗА ЗАКРЫТИЕМ ---
    # Запускаем фоновый цикл: ждем, пока текущее окно (CUR_WID) исчезнет
    (
        bspc subscribe node_remove | while read -r _ _ _ wid; do
            # Если закрытое окно — это то самое, которое было в Zen Mode
            if [ "$wid" = "$CUR_WID" ]; then
                restore_windows
                break
            fi
        done
    ) &
fi
