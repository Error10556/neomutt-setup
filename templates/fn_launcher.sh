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

setup_launcher() {
    mkdir -p "$LOCALBIN"
    if [ ! -f "$LAUNCHERNAME" ] || ! file_is_uptodate "$LAUNCHERNAME"; then
        cat >"$LAUNCHERNAME" <<EOF_LAUNCHER
] ../build/templates/launcher-escaped.sh
EOF_LAUNCHER
        echo "Установлен лаунчер ${CONSOLE_BLUE}emails${CONSOLE_NORMAL}"
    fi
    chmod 750 "$LAUNCHERNAME"
}
