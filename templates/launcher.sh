#!/bin/bash
VERSION=???

] colors.sh

trap 'console.normal; echo; exit 1' INT

for arg in "$@"; do
    if [ "$arg" = "-h" -o "$arg" = "--help" ]; then
        cat <<EOF
Лаунчер emails $VERSION
Использование:
emails --help|-h  (1)
emails name       (2)
emails            (3)

(1) Показать эту справку
(2) Запустить neomutt на любом профиле, начинающемся на 'name'.
(3) Если создан 1 профиль, запустить neomutt на нём.
    Иначе интерактивно выбрать профиль, затем запустить neomutt.

Примеры:
emails t
(Это откроет 'torvalds@linux-foundation.org', если такой профиль существует)
EOF
        exit 0
    fi
done

] fn_dialog.sh

CONFIGS="$HOME/.config/neomutt_setup/configs"

if [ $# -gt 0 ]; then
    configdir="$(find "$CONFIGS" -mindepth 1 \
        -maxdepth 1 -name "$1*" -a -type d | head -n 1)"
    if [ -z "$configdir" ]; then
        echo "Профиль не найден" >&2
        exit 1
    fi
    basename "$configdir"
    exec neomutt -F "$configdir/neomuttrc"
fi

declare -a options=(0=Отмена)
declare -a configdirs=()
configdirs_str="$(find "$CONFIGS" -mindepth 1 -maxdepth 1 -type d)"
i=0
while read -r; do
    test ! -z "$REPLY" || continue
    profile="$(basename "$REPLY")"
    options+=("$((++i))=$profile")
    configdirs+=("$REPLY")
done<<<"$configdirs_str"
unset configdirs_str

if [ $i = 0 ]; then
    echo "Нет профилей"
    exit 1
fi
if [ $i = 1 ]; then
    exec neomutt -F "${configdirs[1]}/neomuttrc"
fi
ans=$(dialog_options "${options[@]}")
if [ $ans = 0 ]; then exit 0; fi
exec neomutt -F "${configdirs[$((ans - 1))]}/neomuttrc"
