# pass_entry_exists <email>
pass_entry_exists() {
    test -f "$HOME/.password-store/mail/$email"
}
