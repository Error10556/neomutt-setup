#!/bin/env bash

] version.sh

] colors.sh

] argparse.sh

] rootcheck.sh

] fn_dialog.sh

] fn_depscheck.sh

depscheck || exit 1

] gpg/fn_all.sh
while ! check_gpg_has_secrets; do
    console.red
    echo "У вас, похоже, нет ключа GPG."
    console.normal
    gpg_setup_guide || exit 0
done

echo "VERSION: $VERSION"
