#!/bin/sh
# Проверить комментарий в первой строке переданных файлов.
if [ "$#" -eq 0 ]; then
    printf 'Usage: %s FILE...\n' "$0" >&2
    exit 1
fi

for file in "$@"; do
    case "$file" in
        *.c|*.js) pattern='^[[:space:]]*(//|/\*)' ;;
        *.py) pattern='^[[:space:]]*#' ;;
        *)
            printf 'SKIP: %s (unsupported extension)\n' "$file"
            continue
            ;;
    esac

    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        printf 'Cannot read file: %s\n' "$file" >&2
        continue
    fi

    first_line=$(head -n 1 < "$file")
    if printf '%s\n' "$first_line" | grep -qE "$pattern"; then
        printf 'OK: %s\n' "$file"
    else
        printf 'NO COMMENT: %s\n' "$file"
    fi
done
