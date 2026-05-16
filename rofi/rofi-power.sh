#!/bin/bash

# Опции меню
shutdown="󰐥    Выключение"
reboot="󰑓    Перезагрузка"
suspend="󰤄    Спящий режим"
hibernate="H    Гиберанция"
exit="󰍃    Выход"
bl="    Блокировка"

# Вызов Rofi
chosen=$(printf "%s\n%s\n%s\n%s\n%s\n%s" "$shutdown" "$reboot" "$suspend" "$hibernate" "$exit" "$bl" | rofi -dmenu -i -p "Завершение работы")

case "$chosen" in
    "$shutdown") sudo poweroff ;;
    "$reboot") sudo reboot ;;
    "$suspend") sudo zzz ;;
    "$hibernate") sudo ZZZ ;;
    "$exit") pkill -u $USER ;;
    "$bl") ~/lock.sh ;;
esac
