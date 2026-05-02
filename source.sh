#!/bin/env bash

] version.sh

] colors.sh

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

echo "VERSION: $VERSION"
