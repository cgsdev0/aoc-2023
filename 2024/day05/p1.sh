#!/bin/bash

FILE="$1"

declare -A deps

parse_rule() {
  first="${1%%|*}"
  second="${1##*|}"
  if [[ -n "${deps[$second]}" ]]; then
    first="${deps[$second]} $first"
  fi
  deps[$second]="$first"
}

split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

parse_update() {
  local -a arr
  local INVALID
  local -a violations
  split "$1" ,
  local -a pages=("${arr[@]}")
  for page in "${pages[@]}"; do
    split "${deps[$page]}" ' '
    for v in "${violations[@]}"; do
      if [[ "$v" == "$page" ]]; then
        INVALID=yes
      fi
    done
    violations+=("${arr[@]}")
  done
  [[ -z "$INVALID" ]] && echo "${pages[@]}"
}

middle() {
  local line
  local -a arr
  while IFS= read -r line; do
    split "$line" ' '
    LEN="${#arr[@]}"
    ((LEN/=2))
    echo ${arr["$LEN"]}
  done
}

while IFS= read -r line; do
  if [[ "$line" == "" ]]; then
    section=2
    continue
  fi

  if [[ $section -eq 2 ]]; then
    parse_update "$line"
  else
    parse_rule "$line"
  fi
done < "$FILE" \
  | middle \
  | paste -sd+ \
  | bc
