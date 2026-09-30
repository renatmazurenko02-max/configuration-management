#!/bin/bash
# Найти пары файлов с одинаковым содержимым.
if [ "$#" -ne 1 ]; then
    printf 'Usage: %s DIRECTORY\n' "$0" >&2
    exit 1
fi

cd -- "$1" || exit 1

find . -type f -print0 | (
    files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done

    for ((i = 0; i < ${#files[@]}; i++)); do
        for ((j = i + 1; j < ${#files[@]}; j++)); do
            if cmp -s -- "${files[i]}" "${files[j]}"; then
                printf 'Duplicate: %s = %s\n' "${files[i]}" "${files[j]}"
            fi
        done
    done
)
