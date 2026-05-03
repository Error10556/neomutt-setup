] fn_dialog_options.sh

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
