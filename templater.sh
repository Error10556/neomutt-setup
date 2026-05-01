#!/bin/bash

trimleft() {
    line="$1"
    while [ ! -z "$line" ]; do
        if [ "${line:0:1}" != " " -a "${line:0:1}" != $'\t' ]; then
            break
        fi
        line="${line:1}"
    done
    printf "%s" "$line"
}

if [ $# = 0 ]; then
    echo "Usage: ./templater.sh <templated file>"
    exit 1
fi

while read line; do
    if [ "${line:0:1}" = ']' ]; then
        cat <templates/"$(trimleft "${line#]}")"
        continue
    fi
    printf $'%s\n' "$line"
done <"$1"
