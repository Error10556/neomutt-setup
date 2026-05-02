print_options() {
    local opt
    for opt in "$@"; do
        local key="${opt%=*}"
        local val="${opt#*=}"
        console.green
        printf "%s" "$key"
        console.normal
        printf $': %s\n' "$val"
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
    echo "${!ok[@]}" >&2
    print_options "$@" >&2
    while :; do
        echo -n 'Ввод> '
        console.green >&2
        local ans
        read ans
        console.normal >&2
        test ! -z "$ans" || continue
        ans="${ans,,}"
        if [ "${ok[$ans]}" = 1 ]; then
            printf "%s" "$ans"
            return 0
        fi
        console.red >&2
        echo 'Такого варианта нет!' >&2
        console.normal >&2
        print_options "$@" >&2
    done
}
