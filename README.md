# dotfiles
## Скриншот
<img width="1920" height="1080" alt="изображение" src="https://github.com/user-attachments/assets/eef59d6c-2419-4583-9a73-3140166b725f" />

Оригинал обоев взят отсюда: https://ru.pinterest.com/pin/882353752013603311/

Слева пришотофоплен вывод fastfetch в xterm, шрифт Terminus 28. Прикляпляю .Xresources для терминала

## Установка

### 1. Установить пакеты:

```
sudo xbps-install -S terminus-font nerd-fonts-symbols-ttf bspwm polybar rofi dbus yad xlockmore maim xdotool xclip jq pulseaudio pavucontrol
```

### 2. Переместить дотфайлы из .config к себе в .config

### 3. Сделать исполняемыми файлы

```
chmod -R 777 ~/.config/bspwm"
chmod -R 777 ~/.config/polybar"
chmod -R 777 ~/.config/rofi"
chmod -R 777 ~/.config/sxhkd
```

### 4. Установить приложение для смены яркости на встроенных мониторах (если надо):

Cкачать и применить устаногвочный скрипт https://github.com/odyazhka/bg

В visudo прописать /usr/local/bin/brightness для смены яркости без пароля



### 5. Для смены рскладки должен существовать файл 00-keyboard.conf в /etc/X11/xorg.conf.d

Переместите его куда если ещё нет и сделайте исполняемым

``` sudo shmod 777 /etc/X11/xorg.conf.d/00-keyboard.conf ```

### 6. Для безпарольного выключения, перезагрузки, гибернации и прочих действий редактируйте visudo:

``` sudo EDITOR=nano visudo ```

Он должен выглядеть примерно вот так:
<img width="653" height="126" alt="изображение" src="https://github.com/user-attachments/assets/54e24de2-e1cf-41bf-884c-f3de2bfa47d4" />

контрл+o, контрл+x
