CONSOLE_RED="$(tput setaf 1)"
CONSOLE_GREEN="$(tput setaf 2)"
CONSOLE_BLUE="$(tput setaf 4)"
CONSOLE_NORMAL="$(tput sgr0)"
console.red() {
    echo -n "$CONSOLE_RED"
}
console.green() {
    echo -n "$CONSOLE_GREEN"
}
console.blue() {
    echo -n "$CONSOLE_BLUE"
}
console.normal() {
    echo -n "$CONSOLE_NORMAL"
}
