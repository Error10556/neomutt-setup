readonly DEPENDENCIES=(sed gpg pass neomutt lynx)
depscheck() {
    dependency_installed() {
        which "$1" &>/dev/null </dev/null
    }
    local -a not_installed
    printf "Установленные зависимости: "
    local first_installed=1
    local dep
    for dep in "${DEPENDENCIES[@]}"; do
        if dependency_installed "$dep"; then
            if [ $first_installed = 1 ]; then
                local first_installed=0
            else
                printf '; '
            fi
            console.green
            printf "%s" "$dep"
            console.normal
        else
            not_installed+=("$dep")
        fi
    done
    if [ $first_installed = 1 ]; then
        console.red
        printf "ни одной"
        console.normal
    fi
    unset first_installed
    echo

    if [ "${#not_installed[@]}" = 0 ]; then
        console.green
        echo "Все зависимости установлены"
        console.normal
        return 0
    else
        printf "Следующие зависимости (%s) " "${#not_installed[@]}"
        console.red
        printf "не установлены"
        console.normal
        echo ":"

        local dep
        for dep in "${not_installed[@]}"; do
            printf "%s" "- "
            console.red
            printf "%s" "$dep"
            console.normal
            echo
        done
        return 1
    fi
}
