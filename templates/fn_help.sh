help_how_to_view_mail() {
    local mails="${CONSOLE_BLUE}emails$CONSOLE_NORMAL"
    local withhelp="${CONSOLE_BLUE}emails -h${CONSOLE_NORMAL}"
    cat <<EOF
Выполните команду $mails, чтоды выбрать профиль и открыть почту. Если создан
только один профиль, то он откроется автоматически.
Выполните команду $withhelp, чтобы увидеть ещё способы.

EOF
}

help_how_to_neomutt() {
    cat <<EOF
Обратите внимание: в верху экрана всегда есть подсказки, какие кнопки сейчас
можно нажать. Вот самые полезные клавиши:
EOF

    # help_key_binding <key> <action>
    help_key_binding() {
        printf "  $CONSOLE_BLUE%s$CONSOLE_NORMAL: %s"$'\n' "$1" "$2"
    }
    
    help_key_binding "j" "Вниз"
    help_key_binding "k" "Вверх"
    help_key_binding "Ctrl+d" "Вниз на полстраницы"
    help_key_binding "Ctrl+u" "Вверх на полстраницы"
    help_key_binding "q" "Выход"
    help_key_binding "Shift+B" "Переключить боковую панель"
    help_key_binding "Ctrl+j" "Выделить следующую папку"
    help_key_binding "Ctrl+k" "Выделить предыдущую папку"
    help_key_binding "Ctrl+e" "Открыть эту папку"
    help_key_binding "Enter" "Открыть письмо"
    help_key_binding "v" "Просмотреть вложения в письме"
    help_key_binding "m" "Написать письмо"

    echo "Перед отправкой письма:"
    help_key_binding "a" "Добавить вложения"
    help_key_binding "p, c" "НЕ зашифровывать и НЕ подписывать с помощью GnuPG"
    help_key_binding "p, e" "Зашифровать с помощью GnuPG"
    help_key_binding "p, s" "Подписать с помощью GnuPG"
    help_key_binding "p, b" "Зашифровать и подписать с помощью GnuPG"
    echo
}

help_after_install() {
    cat <<EOF
Скрипт можно удалить. А когда он снова понадобится, можно его снова скачать.

EOF
}

help_purge() {
    cat <<EOF
Понадобится удалить:
 - Сам скрипт:
${CONSOLE_BLUE}rm neomutt-setup.sh${CONSOLE_NORMAL}
 - Все профили:
${CONSOLE_BLUE}rm -r \$HOME/.config/neomutt_setup${CONSOLE_NORMAL}
 - Все пароли в группе mail (будьте аккуратны, если там уже что-то было Ваше):
${CONSOLE_BLUE}pass rm -r mail${CONSOLE_NORMAL}
 - Кэш писем:
${CONSOLE_BLUE}rm -r \$HOME/.cache/neomutt${CONSOLE_NORMAL}
 - Лаунчер:
${CONSOLE_BLUE}rm \$HOME/.local/bin/emails${CONSOLE_NORMAL}
 - (Опционально) \$HOME/.local/bin из PATH:
${CONSOLE_BLUE}sed -i '/^export PATH="\\\$PATH:$LOCALBIN"$/d' ~/.bashrc
   ${CONSOLE_NORMAL}(Однако лучше сделать это вручную, а не командой)
 - Приложения-зависимости, которые Вам больше не нужны, например, lynx, pass и
   neomutt.
Этот скрипт не автоматизирует удаление.

EOF
}

help_guide() {
    while :; do
        case $(dialog_options "0=В меню" "1=Как открыть почту" \
                "2=Как управлять приложением neomutt" \
                "3=Что делать с neomutt-setup.sh после установки" \
                "4=Как полностью стереть всё, что было установлено"; echo >&2) in
            0) return 0;;
            1) help_how_to_view_mail;;
            2) help_how_to_neomutt;;
            3) help_after_install;;
            4) help_purge;;
        esac
    done
}
