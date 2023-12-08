#!/bin/bash

clear

FILE=input.txt

declare -A map
declare -a starts
declare -a cycles

function main() {
  read instructions
  read
  while read -r key left right; do
    map[$key]="$left $right"
    if [[ "$key" =~ .*A ]]; then
      starts+=($key)
    fi
  done < <(cat \
    | tr -ds '=(,)' ' ')

  for start in "${starts[@]}"; do
    echo "$start"
    curr="$start"
    idx=0
    steps=0
    declare -A visited
    while true; do
      if [[ ! -z ${visited[$curr]} ]]; then
        start_idx="${visited[$curr]}"
        cycle_len=$((steps-start_idx))
        ((start_idx--))
        break
      fi
      visited[$curr]=$steps
      instr=${instructions:idx:1}
      case $instr in
        L)
          curr=${map[$curr]%% *}
          ;;
        R)
          curr=${map[$curr]##* }
          ;;
      esac

      # next instruction
      len=${#instructions}
      idx=$(( (idx+1) % len))
      ((steps++))
    done
    echo "$start_idx $cycle_len"
    cycles+=("$start_idx $cycle_len")
  done

  smallest=$(for cycle in "${cycles[@]}"; do
    read start len <<< "$cycle"
    echo "$len $start"
  done \
    | sort -n \
    | head -n1)

  echo "SMALLEST: $smallest"
  read slen start <<< "$smallest"
  multiple=1
  while true; do
    check=$((multiple*slen + sstart))
    should_break=true
    for cycle in "${cycles[@]}"; do
      read start len <<< "$cycle"
      idk=$(((check - start) % len))
      if [[ $idk -ne 0 ]]; then
        should_break=false
      fi
    done
    if [[ "$should_break" == true ]]; then
      break
    fi
    ((multiple++))
  done
  echo "$multiple"
  echo $((multiple*slen + sstart))
}

main < $FILE
