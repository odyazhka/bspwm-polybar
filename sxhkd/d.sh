#!/bin/sh

# Файл для хранения состояния
STATE_FILE="/tmp/bspwm_zen_mode_$(bspc query -D -d)"

# Если файл состояния существует и в нем есть данные (-s), значит окна скрыты — разворачиваем
if [ -s "$STATE_FILE" ]; then
    # Читаем сохраненные ID построчно
    while read -r wid; do
        # Проверяем, существует ли окно (оно могло быть закрыто), и возвращаем его
        if bspc query -N -n "$wid" > /dev/null 2>&1; then
            bspc node "$wid" -g hidden=off
        fi
    done < "$STATE_FILE"
    
    # Удаляем файл состояния после успешного разворота
    rm -f "$STATE_FILE"
else
    # === ОРИГИНАЛЬНАЯ ЛОГИКА СКРЫТИЯ ===

    # ID всех окон на ТЕКУЩЕМ рабочем столе[cite: 1]
    # Рекомендация: можно заменить на .window.!hidden, чтобы не трогать уже скрытые окна
    ALL_WIDS=$(bspc query -N -d -n .window)

    # Если окон нет — просто выходим[cite: 1]
    [ -z "$ALL_WIDS" ] && exit 0

    # Очищаем/создаем файл перед записью[cite: 1]
    > "$STATE_FILE"

    # Перебираем вообще все окна на десктопе[cite: 1]
    for wid in $ALL_WIDS; do
        # Прячем окно (устанавливаем флаг hidden)[cite: 1]
        bspc node "$wid" -g hidden=on
        
        # Сохраняем ID, чтобы скрипт разворота знал, что возвращать[cite: 1]
        echo "$wid" >> "$STATE_FILE"
    done
fi
