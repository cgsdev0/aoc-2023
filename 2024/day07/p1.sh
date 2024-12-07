#!/bin/bash

FILE="$1"
# FILE="input.txt"

split() {
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

permute() {
  local LEN=${#arr[@]}
  local MAX=$((2**(LEN-1)))
  for ((i=0; i<MAX; i++)); do
    local ACC=${arr[0]}
    # printf "%s " $ACC
    for ((j=1; j<LEN; j++)); do
      local NUM=${arr[$j]}
      if [[ $((i >> (j-1) & 1)) -eq 1 ]]; then
        ((ACC*=NUM))
        # printf "%s " $ACC
      else
        ((ACC+=NUM))
        # printf "%s " $ACC
    fi
    done
    echo "$ACC"
  done
}

while IFS= read -r line; do
  test_number="${line%%:*}"
  rest="${line##*: }"
  split "$rest" " "
  # echo "${arr[@]}"
  # echo "$test_number ${arr[@]}"
  permute \
    | grep "^$test_number$" \
    | head -n1
  # echo "$test_number $RESULT"
done < "$FILE" \
  | paste -sd+ \
  | bc
