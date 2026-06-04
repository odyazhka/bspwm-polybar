#!/bin/sh

# Завершить уже запущенные процессы панели
pkill polybar

# Ожидание закрытия процессов
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    # Запускаем бар, явно передавая переменную MONITOR
    MONITOR=$m polybar --reload main &
done

# Запуск панели
#polybar main -c ~/.config/polybar/config.ini &
