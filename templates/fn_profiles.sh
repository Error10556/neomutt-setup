PROFILEDIR="$HOME/.config/neomutt_setup/configs"

mkdir -p "$PROFILEDIR"

declare -A PROVIDER_PASSWORD_HELP=(["gmail.com"]=gmail_guide)

gmail_guide() {
    echo "${CONSOLE_RED}NOT IMPLEMENTED${CONSOLE_NORMAL}"
}

# pass_insert_guide <email>
# $? != 0  =>  aborted
pass_insert_guide() {
    local blue_email="$CONSOLE_BLUE$email$CONSOLE_NORMAL"
    local provider="${email##*@}"
    provider="${provider,,}"
    local pass_entry_path="$HOME/.password-store/mail/$email.gpg"
    if [ -f "$pass_entry_path" ]; then
        cat <<EOF
Кажется, запись для $blue_email уже есть в менеджере паролей.
EOF
        while :; do
            echo "Что делать?"
            local ans=$(dialog_options \
                "?=Посмотреть, какой там сохранён пароль" \
                "!=${CONSOLE_RED}Удалить${CONSOLE_NORMAL}" \
                ".=Оставить как есть, потому что там правильный пароль")
            echo
            case $ans in
                \?) 
                    pass mail/"$email" || true
                    continue;;
                !) 
                    
                    cat <<EOF
Выполняю ${CONSOLE_RED}rm "$pass_entry_path"${CONSOLE_NORMAL}...
EOF
                    rm "$pass_entry_path";;
                .) return 0;;
            esac
            break
        done
    fi

    local provider_guide="${PROVIDER_PASSWORD_HELP[$provider]}"
    if [ ! -z provider_guide ]; then
        local blue_provider="${CONSOLE_BLUE}$provider${CONSOLE_NORMAL}"
        cat <<EOF
Я могу помочь с получением пароля от адреса под доменом $blue_provider.
EOF
        unset blue_provider
        local ans=$(dialog_options "N=Не нужно" "Y=Да, пожалйуста")
        echo
        test $ans = n || $provider_guide
    fi

    cat <<EOF
Сейчас я запущу команду
${CONSOLE_BLUE}pass insert "mail/$email"${CONSOLE_NORMAL}
Это добавит запись в менеджер паролей. От Вас потребуется дважды ввести пароль
от почты. Заметьте, что это не всегда пароль от учётной записи (например, для
${CONSOLE_BLUE}gmail.com${CONSOLE_NORMAL} этот пароль нужно создавать отдельно).
EOF
    while :; do
        local -a opts=(0=Отмена .=Продолжить)
        if [ ! -z provider_guide ]; then
            opts+=("?=Как получить пароль?")
        fi
        local ans=$(dialog_options "${opts[@]}")
        echo
        case $ans in
            0) return 1;;
            \?)
                $provider_guide || true
                continue;;
            .) break;;
        esac
        break
    done

    while :; do
        pass insert "mail/$email" && break
        console.red
        cat <<EOF
Кажется, программа pass завершилась с ошибкой.
EOF
        local ans=$(dialog_options 0=Отмена ".=Попробовать снова")
        echo
        if [ $ans = 0 ]; then return 1; fi
    done
}

# $? != 0  =>  aborted
new_profile_guide() {
    cat <<EOF
Сейчас мы создадим новый профиль, то есть настроим новый почтовый ящик.
EOF
    local ans=$(dialog_options .=Продолжить 0=Отмена)
    echo
    if [ $ans = 0 ]; then
        return 1
    fi
    while :; do
        echo "Введите адрес электронной почты"
        local email="$(dialog_getline_nonempty)"
        echo
        local blue_email="${CONSOLE_BLUE}$email${CONSOLE_NORMAL}"
        cat <<EOF
Это правильный адрес: $blue_email?
EOF
        local ans=$(dialog_options 0=Отмена "R=Нет, ввести снова" \
            "N=Нет, ввести снова" "Y=Да, продолжить" ".=Да, продолжить")
        echo
        case "$ans" in
            0) return 1;;
            r | n) continue;;
            y | .) ;;
        esac
        break
    done

    if [ -d "$PROFILEDIR/$email" ]; then
        echo "${CONSOLE_RED}Кажется, такой профиль уже есть.$CONSOLE_NORMAL"
        return 1
    fi

    pass_insert_guide "$email" || return 1

    mkdir -p "$PROFILEDIR/$email"

    echo "${CONSOLE_RED}not implemented${CONSOLE_NORMAL}"
}
