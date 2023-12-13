#!/bin/bash

clear

FILE=sample.txt
function rotate() {
  awk '{
    split($0, chars, "")
    for(j=1; j<=length(chars); j++) {
      idx=(j)
      a[idx]=a[idx]chars[j]
    }
  }
  END{ for (i=1; i<=length(a); i++) print a[i] }
    '
}

function debug() {
  return
  echo "$@" 1>&2
}

function solve_line() {
  local len=${#1}
  local row=$2
  local i
  # debug
  # debug
  # debug "$1"
  for ((i=0; i<=((len-2)); i++)); do
    LEFT=${1:0:((i+1))}
    RIGHT=${1:((i+1))}
    if [[ ${#RIGHT} -gt ${#LEFT} ]]; then
      local trim=${#LEFT}
      RIGHT=${RIGHT:0:trim}
    fi
    if [[ ${#LEFT} -gt ${#RIGHT} ]]; then
      local rtrim=${#RIGHT}
      local ltrim=${#LEFT}
      local trim=$((ltrim-rtrim))
      LEFT=${LEFT:trim}
    fi
    debug "LEFT:  $LEFT"
    debug "RIGHT: $RIGHT"
    LEFT="$(echo "$LEFT" | rev)"
    if [[ "$LEFT" == "$RIGHT" ]]; then
      debug "----- $((i+1))"
      echo "$((i+1))"
    else
      echo "NOT $((i+1)) ON $row"
    fi
  done
}

function solve() {
  local line
  local row=0
  data=$(while IFS= read -r line; do
    debug "$line"
    solve_line "$line" "$row"
    ((row++))
  done)
  close=$(echo "$data" \
    | grep -v "NOT" \
    | sort -n \
    | uniq -c \
    | sed 's/^ *//g' \
    | grep "^$(($1-1)) ")

  if [[ ! -z "$close" ]]; then
    read count close_col <<< "$close"
    echo "$data" \
      | grep "NOT $close_col"
  fi
    # | cut -d' ' -f2 \
    # | sed "s/\$/*$2/g" \
    # | paste -sd+ \
    # | bc
}

lines=""
height=1
while IFS= read -r line; do
  if [[ "$line" == "" ]]; then
    # solve $height 1 <<< "$lines"
    solve $width 100 < <(echo "$lines" | rotate)
    break
    lines=""
    height=1
  fi
  if [[ -z "$lines" ]]; then
    lines="$line"
    width="${#line}"
  else
  lines="$lines
$line"
  ((height++))
  fi
done < $FILE
  # | paste -sd+ \
  # | bc
