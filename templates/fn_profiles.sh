PROFILEDIR="$HOME/.config/neomutt_setup/configs"

mkdir -p "$PROFILEDIR"

] provider_password_guides/fn_gmail.sh
] provider_password_guides/fn_yandex.sh

declare -A PROVIDER_PASSWORD_HELP=(["gmail.com"]=gmail_password_guide \
    ["yandex.ru"]=yandex_password_guide)

enum_profiles() {
    test -d "$PROFILEDIR" || return 0
    local lst="$(find "$PROFILEDIR" -mindepth 1 -maxdepth 1 -type d)"
    if [ -z "$lst" ]; then return 0; else
        xargs -n 1 basename <<<"$lst"
    fi
}

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
    local email="$1"
    local blue_email="$CONSOLE_BLUE$email$CONSOLE_NORMAL"
    local provider="${email##*@}"
    provider="${provider,,}"
    if pass_entry_exists "$email"; then
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
Выполняю ${CONSOLE_RED}pass rm -f "mail/$email"${CONSOLE_NORMAL}...
EOF
                    pass rm -f "mail/$email";;
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

# delete_profile_guide <email>
# $? != 0  =>  aborted
delete_profile_guide() {
    prompt() {
        dialog_options Y=Да N=Нет 0=Отмена
        echo >&2
    }

    local email="$1"

    local delete_pass=0
    if pass_entry_exists "$email"; then
        cat <<EOF
Удалить запись из менеджера паролей ${CONSOLE_BLUE}pass${CONSOLE_NORMAL}?
EOF
        case $(prompt) in
            y) delete_pass=1;;
            0) return 1;;
        esac
    fi

    local cache_dir="$HOME/.cache/neomutt/$email"
    local delete_cache=0
    if [ -d "$cache_dir" ]; then
        printf "Удалить кэш писем"
        local cache_size
        if cache_size="$(du -h -d 0 "$cache_dir" 2>/dev/null)"; then
            cache_size="$(grep -Eo '^[^[:space:]]+' <<<"$cache_size")"
            printf " ($CONSOLE_BLUE%s$CONSOLE_NORMAL)" "$cache_size"
        fi
        unset cache_size
        echo "?"
        case $(prompt) in
            y) delete_cache=1;;
            0) return 1;;
        esac
    fi

    echo "${CONSOLE_RED}Я собираюсь выполнить это:${CONSOLE_NORMAL}"
    echo "${CONSOLE_BLUE}# Удалить профиль${CONSOLE_NORMAL}"
    echo "${CONSOLE_RED}rm${CONSOLE_NORMAL} -r $PROFILEDIR/$email"
    if [ $delete_pass = 1 ]; then
        echo "${CONSOLE_BLUE}# Удалить запись pass${CONSOLE_NORMAL}"
        echo "${CONSOLE_RED}pass rm${CONSOLE_NORMAL} -f mail/$email"
    fi
    if [ $delete_cache = 1 ]; then
        echo "${CONSOLE_BLUE}# Удалить кэш${CONSOLE_NORMAL}"
        echo "${CONSOLE_RED}rm${CONSOLE_NORMAL} -r $cache_dir"
    fi
    echo
    echo "Вы уверены?"
    local ans=$(dialog_options Y=Да N=Нет)
    echo
    test $ans = y || return 1
    
    echo "${CONSOLE_BLUE}rm -r $PROFILEDIR/$email${CONSOLE_NORMAL}"
    rm -r "$PROFILEDIR/$email"
    if [ $delete_pass = 1 ]; then
        echo "${CONSOLE_BLUE}pass rm -f mail/$email${CONSOLE_NORMAL}"
        pass rm -f "mail/$email"
    fi
    if [ $delete_cache = 1 ]; then
        echo "${CONSOLE_BLUE}rm -r $cache_dir${CONSOLE_NORMAL}"
        rm -r "$cache_dir"
    fi
    true
}
