gmail_password_guide() {
    prompt() {
        test $(dialog_options "0=Стоп, дальше ясно" ".=Продолжить") = .
    }

    while :; do
        cat <<EOF
Во-первых, включите двухфакторную аутентификацию по ссылке:${CONSOLE_BLUE}
https://myaccount.google.com/signinoptions/twosv${CONSOLE_NORMAL}
EOF
        prompt || return 0
        echo

        cat <<EOF
Теперь Вы можете создать новый пароль приложения. На той же странице перейдите
в "Пароли приложений". Или просто перейдите по ссылке:${CONSOLE_BLUE}
https://myaccount.google.com/apppasswords${CONSOLE_NORMAL}
EOF
        prompt || return 0
        echo

        cat <<EOF
Введите любое название, например, "Neomutt". Нажмите "Создать", скопируйте код.
Он будет выглядеть так: ${CONSOLE_BLUE}abcd efgh ijkl mnop${CONSOLE_NORMAL}.
EOF
        test $(dialog_options "R=Ещё раз" ".=Завершить") = r || break
    done
}
