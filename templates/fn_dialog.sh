print_options() {
    local opt
    for opt in "$@"; do
        local key="${opt%=*}"
        local val="${opt#*=}"
        printf "%s%s%s: %s\n" "$CONSOLE_BLUE" "$key" "$CONSOLE_NORMAL" "$val"
    done
}

dialog_getline_or_empty() {
    echo -n 'Ввод> ' >&2
    console.green >&2
    local ans
    read ans
    console.normal >&2
    printf '%s' "$ans"
}

dialog_getline_nonempty() {
    while :; do
        ans="$(dialog_getline_or_empty)"
        test ! -z "$ans" || continue
        printf '%s' "$ans"
        return 0
    done
}

dialog_options() {
    local -A ok
    local opt
    for opt in "$@"; do
        local key="${opt%=*}"
        local key=${key,,}
        local val="${opt#*=}"
        ok["$key"]=1
    done
    while :; do
        print_options "$@" >&2
        ans="$(dialog_getline_nonempty)"
        ans="${ans,,}"
        if [ "${ok[$ans]}" = 1 ]; then
            printf "%s" "$ans"
            return 0
        fi
        echo "${CONSOLE_RED}Такого варианта нет!${CONSOLE_NORMAL}" >&2
    done
}

options_multisel() {
    local -A keys
    local opt
    for opt in "$@"; do
        local key="${opt%=*}"
        local key=${key,,}
        local val="${opt#*=}"
        keys["$key"]=1
    done
    local -A selection
    while :; do
        if [ ${#selection[@]} = 0 ]; then
            print_options 0=Отмена >&2
        else
            print_options 0=Сброс ".=Подтвердить выбор" >&2
        fi
        for opt in "$@"; do
            local key="${opt%=*}"
            local key=${key,,}
            local val="${opt#*=}"
            if [ "${selection[$key]}" = 1 ]; then
                printf "${CONSOLE_GREEN}%s${CONSOLE_NORMAL}: " "$key" >&2
                printf "${CONSOLE_GREEN}[${CONSOLE_NORMAL}%s" "$val" >&2
                echo "${CONSOLE_GREEN}]${CONSOLE_NORMAL}" >&2
            else
                print_options "$opt" >&2
            fi
        done

        local ans="$(dialog_getline_nonempty)"
        case "$ans" in
            0) if [ "${#selection[@]}" = 0 ]; then
                return 1
            else
                local key
                for key in "${!selection[@]}"; do
                    unset selection[$key]
                done
            fi;;
            .) if [ "${#selection[@]}" = 0 ]; then
                echo "${CONSOLE_RED}Надо выбрать что-нибудь${CONSOLE_NORMAL}"
            else
                local sel
                for sel in "${!selection[@]}"; do printf "%s\n" "$sel"; done \
                    | sort
                return 0
            fi;;
            *) if [ "${keys[$ans]}" != 1 ]; then
                echo "${CONSOLE_RED}Такого варианта нет!${CONSOLE_NORMAL}"
            else
                if [ "${selection[$ans]}" = 1 ]; then
                    unset selection[$ans]
                else
                    selection[$ans]=1
                fi
            fi;;
        esac
    done
}
