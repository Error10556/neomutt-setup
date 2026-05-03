VERSION=0.0.0

file_is_uptodate() {
    local versionstr="$(head -n 2 "$1" | tail -n 1)"
    test "$versionstr" = "#VERSION $VERSION"
}
