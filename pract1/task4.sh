#!/bin/sh
# Вывести уникальные идентификаторы из указанного файла.
if [ "$#" -ne 1 ]; then
    printf 'Usage: %s FILE\n' "$0" >&2
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    printf 'Cannot read file: %s\n' "$1" >&2
    exit 1
fi
LC_ALL=C grep -oE '[a-zA-Z_][a-zA-Z0-9_]*' < "$1" | LC_ALL=C sort -u
