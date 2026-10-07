# Практическое занятие №1

Введение, основы работы в командной строке.

[Условия заданий](https://github.com/true-grue/kisscm/blob/main/pract/pract1.md)

Среда выполнения: Alpine Linux в JSLinux, оболочки sh и Bash.
Ниже приведены исходные коды всех десяти решений и примеры запуска.
Команды запуска выполняются из папки с файлами решений.
При запуске через `sh` или `bash` отдельное разрешение на исполнение файла не требуется.

## Задача 1. Имена пользователей по алфавиту

Файл: [task1.sh](task1.sh).

Из каждой строки `/etc/passwd` извлекается имя до первого двоеточия. Полученный список сортируется.

```sh
#!/bin/sh
# Задача 1. Вывести имена пользователей по алфавиту.
grep -o '^[^:]*' /etc/passwd | sort
```

Запуск:

```sh
sh task1.sh
```

Список пользователей зависит от системы.

## Задача 2. Пять протоколов с наибольшими номерами

Файл: [task2.sh](task2.sh).

Из `/etc/protocols` выбираются строки с числовым вторым полем. Выводятся номер и название, затем записи сортируются по убыванию номера. В этом файле хранятся номера протоколов, хотя в условии использовано слово «порты».

```sh
#!/bin/sh
# Задача 2. Вывести пять протоколов с наибольшими номерами.
awk '{print $2, $1}' /etc/protocols | sort -nr | head -n 5
```

Запуск:

```sh
sh task2.sh
```

Результат в использованной системе:

```text
262 mptcp
143 ethernet
142 rohc
141 wesp
140 shim6
```

## Задача 3. Текстовый баннер

Файл: [banner](banner).

Ширина рамки вычисляется по длине переданного текста с добавлением двух пробелов по краям. Пример рассчитан на однострочный текст с обычными символами, как в условии.

```bash
#!/bin/bash
# Вывод переданного текста в рамке.
text="$*"
printf -v border '%*s' "$(( ${#text} + 2 ))" ''
border=${border// /-}
printf '+%s+\n| %s |\n+%s+\n' "$border" "$text" "$border"
```

Запуск:

```sh
bash banner "Hello from RTU MIREA!"
bash banner "Hi"
```

Результат второго запуска:

```text
+----+
| Hi |
+----+
```

Код проверен в ShellCheck: `No issues detected!`.

## Задача 4. Уникальные идентификаторы

Файл: [task4.sh](task4.sh).

Используется шаблон из латинских букв, цифр и символа `_`, начинающийся с буквы или `_`. Как в примере задания, слова извлекаются из всего текста, включая строки и комментарии; ключевые слова также остаются в выводе. Это обработка текста регулярным выражением, а не полный лексический анализатор C/C++ или Java.

```sh
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
LC_ALL=C grep -o '[a-zA-Z_][a-zA-Z0-9_]*' < "$1" | LC_ALL=C sort -u
```

Тестовый файл [hello.c](hello.c):

```c
#include <stdio.h>
int main(void) {
    printf("hello world\n");
    return 0;
}
```

Запуск:

```sh
sh task4.sh hello.c
```

Результат:

```text
h
hello
include
int
main
n
printf
return
stdio
void
world
```

## Задача 5. Установка пользовательской команды

Файл: [reg](reg).

Команда `install` копирует файл в `/usr/local/bin` и задаёт права `755`: владелец может читать, изменять и запускать, остальные могут читать и запускать. Требуются права записи в `/usr/local/bin`; в использованной среде программа запускалась от root. Существующий файл с тем же именем заменяется.

```sh
#!/bin/sh
# Установить пользовательскую команду в /usr/local/bin.
if [ "$#" -ne 1 ]; then
    printf 'Usage: %s FILE\n' "$0" >&2
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    printf 'Cannot read file: %s\n' "$1" >&2
    exit 1
fi
name=$(basename -- "$1")
mkdir -p /usr/local/bin || exit 1
install -m 755 -- "$1" "/usr/local/bin/$name" || exit 1
printf 'Installed: /usr/local/bin/%s\n' "$name"
```

Запуск и проверка:

```sh
sh reg banner
ls -l /usr/local/bin/banner
banner "Hi"
```

Проверены права `-rwxr-xr-x` и запуск установленной команды без `./`.
Для поиска команды каталог `/usr/local/bin` должен входить в `PATH`.

## Задача 6. Комментарий в первой строке

Файл: [task6.sh](task6.sh).

Программа принимает имена файлов. Для `.c` и `.js` проверяется начало первой строки с `//` или `/*`, для `.py` с `#`. Перед комментарием допускаются пробельные символы.

Допущение: проверяется комментарий в начале строки после пробелов. Комментарий после программного кода в той же строке этим решением не распознаётся.

```sh
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
```

Подготовка примеров и запуск:

```sh
mkdir -p test6
printf '// Comment\n' > test6/example.c
printf 'console.log("Hi");\n' > test6/example.js
printf '# Comment\n' > test6/example.py
sh task6.sh test6/*
```

Результат:

```text
OK: test6/example.c
NO COMMENT: test6/example.js
OK: test6/example.py
```

## Задача 7. Поиск файлов-дубликатов

Файл: [task7.sh](task7.sh).

Поиск охватывает указанную папку и подпапки. Команда `cmp` сравнивает содержимое файлов, программа выводит каждую совпавшую пару один раз. Для трёх одинаковых файлов будут выведены три пары. Попарное сравнение подходит для небольших наборов файлов, но медленно работает при большом их количестве.

```bash
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
```

Подготовка примеров и запуск:

```sh
mkdir -p test7/sub
printf 'Hello\n' > test7/a.txt
cp test7/a.txt test7/sub/b.txt
printf 'Other\n' > test7/c.txt
bash task7.sh test7
```

Результат, порядок файлов может отличаться:

```text
Duplicate: ./sub/b.txt = ./a.txt
```

## Задача 8. Архивирование файлов по расширению

Файл: [task8.sh](task8.sh).

Аргументы: папка и расширение (`txt` или `.txt`). Проверяются файлы непосредственно в указанной папке, включая скрытые. Архив `archive.tar` создаётся в этой же папке и исключается из списка входных файлов. При повторном запуске существующий архив заменяется.

```bash
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
```

Подготовка примеров, запуск и просмотр архива:

```sh
mkdir -p test8
printf 'First\n' > test8/a.txt
printf 'Second\n' > test8/b.txt
printf 'Other\n' > test8/c.log
bash task8.sh test8 txt
tar -tf test8/archive.tar
```

Содержимое архива:

```text
./a.txt
./b.txt
```

## Задача 9. Замена четырёх пробелов табуляцией

Файл: [task9.sh](task9.sh).

Аргументы: входной и выходной файлы. Каждые четыре последовательных пробела заменяются одним символом табуляции, в том числе в середине строки. Восемь пробелов дают две табуляции. Входной и выходной файлы должны различаться. Существующий выходной файл перезаписывается.

```bash
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
```

Подготовка примера, запуск и проверка:

```sh
printf '    Hello\n        World\nA    B\n' > input9.txt
bash task9.sh input9.txt output9.txt
cat -t output9.txt
```

Результат, где `^I` обозначает табуляцию:

```text
^IHello
^I^IWorld
A^IB
```

## Задача 10. Пустые текстовые файлы

Файл: [task10.sh](task10.sh).

Допущение: текстовыми считаются файлы с расширением `.txt`. Это ограничение данного решения, расширение не указано в исходном условии. По содержимому файла размером 0 байт определить его предполагаемый тип нельзя.

Проверяются файлы непосредственно в указанной папке, включая скрытые. Пустой файл имеет размер 0 байт. Файл с пробелом или переводом строки пустым не считается.

```bash
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
```

Подготовка примеров и запуск:

```sh
mkdir -p test10
printf '' > test10/empty.txt
printf 'Hello\n' > test10/full.txt
printf ' ' > test10/space.txt
printf '' > test10/empty.log
bash task10.sh test10
```

Результат:

```text
empty.txt
```

## Проверка

Примеры запуска выполнены в JSLinux. Исходные коды для анализа в [ShellCheck](https://www.shellcheck.net/) вставляются целиком, начиная с `#!`, без команд создания файлов и строк `EOF`.

ShellCheck проверяет типичные ошибки shell-кода. Отсутствие замечаний не заменяет проверку поведения программы на входных данных.
