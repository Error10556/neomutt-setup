LOCALBIN="$HOME/.local/bin"
LAUNCHERNAME="$LOCALBIN/emails"

path_contains_localbin() {
    local IFS=':'
    for path in $PATH; do
        if [ "$path" = "$LOCALBIN" ]; then
            return 0
        fi
    done
    return 1
}

add_localbin_to_path_bashrc() {
    cat >>"$HOME/.bashrc" <<EOF
export PATH="\$PATH:$LOCALBIN"
EOF
}

need_overwrite_launcher() {
    ver_regex="$(sed 's/\./\\./g' <<<"$VERSION")"
    ! head -n 2 "$LAUNCHERNAME" | tail -n 1 \
        | grep -E -o "^VERSION=$ver_regex\$" &>/dev/null
}

setup_launcher() {
    mkdir -p "$LOCALBIN"
    if [ ! -f "$LAUNCHERNAME" ] || need_overwrite_launcher; then
        cat >"$LAUNCHERNAME" <<EOF_LAUNCHER
] launcher.sh
EOF_LAUNCHER
        echo "Установлен лаунчер ${CONSOLE_BLUE}emails${CONSOLE_NORMAL}"
    fi
    chmod 550 "$LAUNCHERNAME"
}
