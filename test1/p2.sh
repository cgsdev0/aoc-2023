#!/bin/bash

clear

FILE=input.txt

declare -A counts
while read c n; do
  counts[$n]=$c
done < <(tr -s ' ' < "$FILE" \
  | cut -d' ' -f2 \
  | sort -n \
  | uniq -c \
  | tr -s ' ' \
  | cut -d' ' -f2-3)

while read n; do
  echo "$n*${counts[$n]:-0}"
done < <(tr -s ' ' < "$FILE" | cut -d' ' -f1) \
  | paste -sd+ \
  | bc
