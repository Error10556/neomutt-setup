# gpg_adduid_guide <email>
# #? != 0  =>  aborted
gpg_adduid_guide() {
    local email="$1"
    local blue_email="$CONSOLE_BLUE$email$CONSOLE_NORMAL"
    cat <<EOF
Нужно добавить Ваш адрес <$blue_email> в GnuPG.
Выберите, пожалуйста, одну из существующих записей, с которой связать новую.
EOF
    local -a options=(0=Отмена "-=Стоп, я разберусь самостоятельно")
    local identities_str="$(gpg_identities_with_secrets)"
    local colored_ids_str="$(color_emails_in_angles <<<"$identities_str")"
    local existing_emails_str="$(extract_emails_from_angles \
        <<<"$identities_str")"
    unset identities_str
    local -a existing_emails=()
    local i=0
    while read -r; do
        options+=("$((++i))=$REPLY")
    done<<<"$colored_ids_str"
    unset colored_ids_str
    while read -r; do
        existing_emails+=("$REPLY")
    done<<<"$existing_emails_str"
    unset existing_emails_str

    local ans=$(dialog_options "${options[@]}")
    echo
    local chosen_existing_id
    case $ans in
        0) return 1;;
        -) test $(dialog_options 0=Отмена .=Продолжить) = .; return $?;;
        *) local chosen_existing_id="${existing_emails[$((i - 1))]}";;
    esac

    echo "Введите своё имя, которое хотите связать с <$blue_email>"
    while :; do
        local realname="$(dialog_getline_nonempty)"
        echo
        cat <<EOF
Это имя правильное: ${CONSOLE_BLUE}$realname${CONSOLE_NORMAL}?
EOF
        case $(dialog_options 0=Отмена "-=Нет, ввести ещё раз" \
                "R=Нет, ввести ещё раз" "N=Нет, ввести ещё раз" \
                ".=Да, продолжить" "Y=Да, продолжить") in
            0) return 1;;
            - | r | n) continue;;
            . | y) break;;
        esac
    done
    echo

    echo "Выполняем:"
    console.blue
    cat <<EOF
gpg --quick-adduid "$chosen_existing_id" "$realname <$email>"
EOF
    console.normal
    if gpg --quick-adduid "$chosen_existing_id" "$realname <$email>"; then
        console.blue
        cat <<EOF
gpg --check-trustdb
EOF
        console.normal
        if gpg --check-trustdb; then
            return 0
        fi
    fi
    console.red
    echo "Программа gpg завершилась с ошибкой. Прерываем сценарий."
    console.normal
    return 1
}

# gpg_adduid_guide_if_needed <email>
gpg_adduid_guide_if_needed() {
    ! gpg_identities_with_secrets | grep -F "<$email>" &>/dev/null || return 0
    console.red
    cat <<EOF
Похоже, $1 отсутствует в GnuPG.
EOF
    console.normal
    gpg_adduid_guide "$1"
}
