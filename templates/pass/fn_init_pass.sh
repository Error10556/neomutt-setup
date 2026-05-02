pass_directory_exists() {
    test -d "$HOME/.password-store"
}

# $? = 1   =>  aborted
guide_setup_pass() {
    echo "Сейчас я выполню команду:"
    console.blue
    echo "pass init <идентификаторы>"
    console.normal
    local pas="${CONSOLE_BLUE}pass${CONSOLE_NORMAL}"
    cat <<EOF
Это настроит менеджер паролей $pas для использования с email-клиентом. Этот
установщик не поддерживает других способов хранения паролей.
EOF
    local ans="$(dialog_options "0=Стоп, я разберусь самостоятельно" \
        "1=Продолжить")"
    if [ $ans = 0 ]; then
        return 1
    fi
    cat <<EOF
Выберите идентификаторы GnuPG, для которых нужно шифровать пароли.
EOF

    enumerate() {
        i=0
        while read -r; do
            printf "%s=%s" $((++i)) "$REPLY"
        done
    }
    local -a opts
    local i=0
    local ids="$(gpg_identities_with_secrets)"
    local colored_ids="$(sed -E \
        "s/(.*)<([^>]*)>(.*)/\\1<${CONSOLE_BLUE}\\2${CONSOLE_NORMAL}>\\3/" \
        <<<"$ids")"
    local emails_str="$(sed -E 's/.*<([^>]*)>.*/\1/' <<<"$ids")"
    unset ids
    local -a emails
    while read -r; do
        emails+=("$REPLY")
    done<<<"$emails_str"
    unset emails_str
    while read -r; do
        opts+=("$((++i))=$REPLY")
    done<<<"$colored_ids"
    unset colored_ids

    local chosen_inds="$(options_multisel "${opts[@]}")"
    if [ $? != 0 -o -z "$chosen_inds" ]; then
        return 1
    fi
    local -a chosen_emails
    while read -r; do
        chosen_emails+=("${emails[$((REPLY - 1))]}")
    done <<<"$chosen_inds"
    if ! pass init "${chosen_emails[@]}"; then
        console.red
        cat <<EOF
Программа pass завершилась с ошибкой. Прерываем установщик.
EOF
        console.normal
        exit 1
    fi
}
