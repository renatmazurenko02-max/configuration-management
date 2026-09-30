#!/bin/bash
# Заменить каждые четыре пробела символом табуляции.
if [ "$#" -ne 2 ]; then
    printf 'Usage: %s INPUT OUTPUT\n' "$0" >&2
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    printf 'Cannot read file: %s\n' "$1" >&2
    exit 1
fi

if [[ "$1" -ef "$2" ]]; then
    printf 'Input and output must be different files\n' >&2
    exit 1
fi

tab=$(printf '\t')
sed "s/    /$tab/g" < "$1" > "$2" || exit 1
printf 'Saved: %s\n' "$2"
