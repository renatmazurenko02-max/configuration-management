#!/bin/bash
# Архивировать файлы указанного расширения.
if [ "$#" -ne 2 ]; then
    printf 'Usage: %s DIRECTORY EXTENSION\n' "$0" >&2
    exit 1
fi

extension=${2#.}
if [ -z "$extension" ] || [[ "$extension" == */* ]]; then
    printf 'Invalid extension\n' >&2
    exit 1
fi

cd -- "$1" || exit 1
shopt -s nullglob dotglob
files=()

for file in ./*."$extension"; do
    if [ -f "$file" ] && [ "$file" != "./archive.tar" ]; then
        files+=("$file")
    fi
done

if [ "${#files[@]}" -eq 0 ]; then
    printf 'No matching files\n'
    exit 0
fi

tar -cf archive.tar "${files[@]}" || exit 1
printf 'Created: archive.tar\n'
