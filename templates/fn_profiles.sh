PROFILEDIR="$HOME/.config/neomutt_setup/configs"

mkdir -p "$PROFILEDIR"

] provider_password_guides/fn_gmail.sh
] provider_password_guides/fn_yandex.sh

declare -A PROVIDER_PASSWORD_HELP=(["gmail.com"]=gmail_password_guide \
    ["yandex.ru"]=yandex_password_guide)

# make_profile <email> <realname> <editor>
make_profile() {
    local RC_FROM="$1"
    local RC_REALNAME="$2"
    local RC_EDITOR="$3"
    local RC_PGPKEY
    RC_PGPKEY="$(gpg_get_fpr "$1")"
    test $? = 0 || return 1
    local dir="$PROFILEDIR/$1"
    mkdir -p "$dir" || return 1
    local provider="${1##*@}"
    provider="${provider,,}"
    case "$provider" in
        gmail.com)
            cat >"$dir/neomuttrc" <<NEOMUTTRC_EOF
] rc/gmail.rc
NEOMUTTRC_EOF
            test $? = 0 || return 1
            ;;
        yandex.ru)
            cat >"$dir/neomuttrc" <<NEOMUTTRC_EOF
] rc/yandex.rc
NEOMUTTRC_EOF
            test $? = 0 || return 1
            ;;
        *)
            local warning="${CONSOLE_RED}ВНИМАНИЕ${CONSOLE_NORMAL}"
            cat <<EOF
$warning: $provider мне (пока) неизвестен, поэтому настраиваю на авось. Если
почта не откроется, Вам придётся менять конфиг самостоятельно! Путь:
$CONSOLE_BLUE$dir/neomuttrc$CONSOLE_NORMAL
EOF
            cat >"$dir/neomuttrc" <<NEOMUTTRC_EOF
] rc/_generic.rc
NEOMUTTRC_EOF
            test $? = 0 || return 1
            ;;
    esac
    cat >"$dir/mailcap" <<MAILCAP_EOF
] rc/mailcap.rc
MAILCAP_EOF
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
Похоже, запись для $blue_email уже есть в менеджере паролей.
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
    if [ ! -z "$provider_guide" ]; then
        local blue_provider="${CONSOLE_BLUE}$provider${CONSOLE_NORMAL}"
        cat <<EOF
Я могу помочь с получением пароля от адреса под доменом $blue_provider.
EOF
        unset blue_provider
        local ans=$(dialog_options "N=Не нужно" "Y=Да, пожалйуста")
        echo
        test $ans = n || $provider_guide
    fi

    local blugmail="${CONSOLE_BLUE}gmail.com${CONSOLE_NORMAL}"
    local bluyandx="${CONSOLE_BLUE}yandex.ru${CONSOLE_NORMAL}"
    cat <<EOF
Сейчас я запущу команду
${CONSOLE_BLUE}pass insert "mail/$email"${CONSOLE_NORMAL}
Это добавит запись в менеджер паролей. От Вас потребуется дважды ввести пароль
от почты. Заметьте, что это не пароль от учётной записи (например, для $blugmail
и $bluyandex этот пароль нужно создавать отдельно).
EOF
    while :; do
        local -a opts=(0=Отмена .=Продолжить)
        if [ ! -z "$provider_guide" ]; then
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
Похоже, программа pass завершилась с ошибкой.
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
        echo "${CONSOLE_RED}Похоже, такой профиль уже есть.$CONSOLE_NORMAL"
        return 1
    fi

    gpg_adduid_guide_if_needed "$email" || return 1

    pass_insert_guide "$email" || return 1

    local realname="$(gpg_identities_with_secrets | grep -F "<$email>")"
    realname="${realname%% <*}"
    realname="${realname%% (*}"

    local nan="${CONSOLE_BLUE}nano${CONSOLE_NORMAL}"
    local vi="${CONSOLE_BLUE}vim${CONSOLE_NORMAL}"
    local nvi="${CONSOLE_BLUE}nvim${CONSOLE_NORMAL}"
    cat <<EOF
Последний вопрос: какой консольный редактор Вы используете (вроде $nan, $vi,
$nvi)? Если Вы не знаете, то напишите ${CONSOLE_GREEN}nano${CONSOLE_NORMAL}.
EOF
    while :; do
        local editor="$(dialog_getline_nonempty)"
        echo
        ! which "$editor" &>/dev/null </dev/null || break
        console.red
        cat <<EOF
Кажется, такой программы нет в системе. Вы не опечатались?
EOF
        test $(dialog_options "R=Ввести заново" ".=Всё правильно") = r || break
        echo
    done

    if make_profile "$email" "$realname" "$editor"; then
        console.green
        cat <<EOF
Профиль $email успешно создан. Принимайте работу ;)
EOF
        console.normal
        return 0
    fi
    console.red
    cat <<EOF
Создать профиль не удалось. Почему? Надеюсь, чуть выше вывелись сообщения об
ошибках, там, может, будет сказано. Простите за потраченное время.

EOF
    if [ -d "$PROFILEDIR/$email" ]; then
        echo "Удаляю директорию $email..."
        rm -r "$PROFILEDIR/$email" || true
        echo
    fi
    console.normal
}
