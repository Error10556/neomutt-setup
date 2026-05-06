# gpg_get_fpr <id>
gpg_get_fpr() {
    gpg --list-keys --with-colons "$1" | grep -E "^fpr:" | head -n 1 \
        | cut -d: -f10
}
