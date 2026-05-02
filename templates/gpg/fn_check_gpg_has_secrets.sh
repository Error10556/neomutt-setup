check_gpg_has_secrets() {
    gpg --list-secret-keys --with-colons 2>&1 | grep -E '^sec:' &>/dev/null
}
