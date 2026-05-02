#!/bin/bash
] version.sh

for arg in "\$@"; do
    if [ "\$arg" = "-h" -o "\$arg" = "--help" ]; then
        cat <<EOF
VERSION \$VERSION
Usage:
\$0 --help|-h  (1)
\$0 [name]     (2)

(1) Show this message
(2) If name is specified, launch neomutt on any profile starting with 'name'.
    Otherwise, launch neomutt on any profile.

Examples:
\$0 t
(this would open 'torvalds@linux-foundation.org' if such a profile existed)
EOF
    fi
done

if [ \$# -gt 0 ]; then
    configdir="\$(find ~/.config/neomutt_setup/configs/ -mindepth 1 \\
        -maxdepth 1 -name "\$1*" -a -type d | head -n 1)"
    if [ -z "\$configdir" ]; then
        echo "Profile not found" >&2
        exit 1
    fi
    basename "\$configdir"
    neomutt -F "\$configdir/neomuttrc"
else
    "\$0" ""
fi
