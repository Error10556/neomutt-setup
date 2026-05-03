yandex_password_guide() {
    prompt() {
        test $(dialog_options "0=Стоп, дальше ясно" ".=Продолжить") = .
    }

    while :; do
        cat <<EOF
Перейдите по ссылке:${CONSOLE_BLUE}
https://id.yandex.ru/security/app-passwords${CONSOLE_NORMAL}
EOF
        prompt || return 0
        echo

        cat <<EOF
Нажмите "Почта" и введите любое название, например, "Neomutt".
Затем нажмите "Далее", скопируйте код. Он будет выглядеть так:
  ${CONSOLE_BLUE}qwertyuiopasdfgh${CONSOLE_NORMAL}.
EOF
        test $(dialog_options "R=Ещё раз" ".=Завершить") = r || break
    done
}
