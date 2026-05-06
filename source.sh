#!/bin/env bash

] version.sh
] fn_version.sh

] colors.sh

cat <<EOF
Neomutt Setup $VERSION
Тимур Усманов, 2026
На условиях GNU General Public License v3
EOF

trap 'console.normal; echo; exit 1' INT

] argparse.sh

] rootcheck.sh

] fn_dialog.sh

] fn_depscheck.sh

depscheck || exit 1

] gpg/fn_all.sh
while ! check_gpg_has_secrets; do
    echo "${CONSOLE_RED}У Вас, похоже, нет ключа GPG.${CONSOLE_NORMAL}"
    gpg_setup_guide || exit 0
done

] pass/fn_init_pass.sh

if ! pass_directory_exists; then
    echo "${CONSOLE_RED}У Вас, похоже, не настроен pass.${CONSOLE_NORMAL}"
    guide_setup_pass || exit 1
fi

] fn_launcher.sh
if ! path_contains_localbin; then
    echo "${CONSOLE_RED}Похоже, ~/.local/bin не входит в PATH${CONSOLE_NORMAL}"
    while :; do
        ans=$(dialog_options "0=Стоп, я разберусь самостоятельно" \
            "!=Добавить запись ~/.local/bin в PATH с помощью записи в .bashrc" \
            "?=Зачем добавлять ~/.local/bin?")
        case $ans in
            0) exit 1;;
            !)
                add_localbin_to_path_bashrc
                console.red
                echo "ПОЖАЛУЙСТА, перезапустите терминал сейчас!"
                console.normal
                exit 0;;
            \?)
                mlscr="${CONSOLE_BLUE}emails${CONSOLE_NORMAL}"
                cat <<EOF
Я добавлю скрипт $mlscr в эту папку. С его помощью можно будет открывать почту.
EOF
                ;;
        esac
    done
fi
setup_launcher

] fn_profiles.sh

main_action() {
    declare -a options=("+=Добавить почтовый ящик")
    i=0
    profiles_str="$(enum_profiles)"
    declare -a profiles=()
    while read -r; do
        test ! -z "$REPLY" || continue
        profiles+=("$REPLY")
        options+=("$((++i))=${CONSOLE_RED}Удалить${CONSOLE_NORMAL} $REPLY")
    done <<<"$profiles_str"
    options+=("0=Выйти" "Q=Выйти")
    ans=$(dialog_options "${options[@]}")
    echo
    case $ans in
        +) new_profile_guide || true;;
        0 | q) exit 0;;
        *) delete_profile "${profiles[$((ans - 1))]}";;
    esac
}

while :; do echo; main_action; done
