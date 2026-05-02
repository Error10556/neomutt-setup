check_gpg_has_public() {
    gpg --list-keys "$1" &>/dev/null
}
