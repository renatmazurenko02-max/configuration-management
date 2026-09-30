#!/bin/bash
# Вывести имена пустых файлов с расширением .txt.
if [ "$#" -ne 1 ]; then
    printf 'Usage: %s DIRECTORY\n' "$0" >&2
    exit 1
fi

cd -- "$1" || exit 1
shopt -s nullglob dotglob

for file in ./*.txt; do
    if [ -f "$file" ] && [ ! -s "$file" ]; then
        printf '%s\n' "${file#./}"
    fi
done
