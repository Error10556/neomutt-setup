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
    declare -A ok
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
