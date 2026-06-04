#!/bin/sh

FLAG="/tmp/polybar_date_toggle"
if [ "$1" = "toggle" ]; then
    if [ -f "$FLAG" ]; then
        rm "$FLAG"
    else
        touch "$FLAG"
    fi
    exit 0
fi

if [ -f "$FLAG" ]; then
    date +"%d.%m.%Y"
else
    LANG=ru_RU.UTF-8 date +"%a, %-d %B"
fi
