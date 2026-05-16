#!/bin/sh

# Файл для хранения состояния (убедись, что переменная STATE_FILE задана выше)
STATE_FILE="/tmp/bspwm_zen_mode_$(bspc query -D -d)"

# ID всех окон на ТЕКУЩЕМ рабочем столе
ALL_WIDS=$(bspc query -N -d -n .window)

# Если окон нет — просто выходим
[ -z "$ALL_WIDS" ] && exit 0

# Очищаем файл перед записью
> "$STATE_FILE"

# Перебираем вообще все окна на десктопе
for wid in $ALL_WIDS; do
    # Прячем окно (устанавливаем флаг hidden)
    bspc node "$wid" -g hidden=on
    
    # Сохраняем ID, чтобы скрипт разворота знал, что возвращать
    echo "$wid" >> "$STATE_FILE"
done
