file_is_uptodate() {
    local versionstr="$(grep -E '^VERSION=' <"$1" | head -n 1)"
    test "$versionstr" = "VERSION=$VERSION"
}
