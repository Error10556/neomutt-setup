check_gpg_has_secrets() {
    gpg --list-secret-keys --with-colons 2>&1 | grep -E '^sec:' &>/dev/null
}

gpg_identities_with_secrets() {
    gpg --list-secret-keys --with-colons 2>/dev/null | grep -E '^uid:' \
        | cut -d: -f10
}

gpg_identities() {
    gpg --list-keys --with-colons 2>/dev/null | grep -E '^uid:' | cut -d: -f10
}

# stdin: gpg_identities[_with_secrets]
color_emails_in_angles() {
    sed -E "s/(.*)<([^>]*)>(.*)/\\1<${CONSOLE_BLUE}\\2${CONSOLE_NORMAL}>\\3/"
}

# stdin: gpg_identities[_with_secrets]
extract_emails_from_angles() {
    sed -E 's/.*<([^>]*)>.*/\1/'
}
