#!/bin/sh
# Задача 2. Вывести пять протоколов с наибольшими номерами.
awk '{print $2, $1}' /etc/protocols | sort -nr | head -n 5
