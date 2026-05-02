check_gpg_has_secrets() {
    gpg --list-secret-keys --with-colons 2>&1 | grep -E '^sec:' &>/dev/null
}

gpg_identities_with_secrets() {
    gpg --list-secret-keys --with-colons 2>/dev/null | grep -E '^uid:' \
        | cut -d: -f10
}
