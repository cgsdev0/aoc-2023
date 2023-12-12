#!/bin/bash

clear

FILE=sample.txt

function descend() {
  local record=$1
  local sizes=$2
  local iter=$3
  local size=${sizes%%,*}
  local count=0
  local hard=0
  local idx=0
  while read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi
    if [[ "$char" == "#" ]] || [[ "$char" == "?" ]]; then
      if [[ "$char" == "#" ]]; then
        ((hard++))
      fi
      ((count++))
      if [[ $count -ge $size ]]; then
        if [[ ${record:((idx+1)):1} != "#" ]]; then
          if [[ "$sizes" =~ , ]]; then
            #
            descendant=${record:((idx+2))}
            if [[ ! -z $descendant ]]; then
              echo "$iter       $record"
              echo descend ${record:((idx+2))} ${sizes#*,}
              echo
              descend $descendant ${sizes#*,} $((iter+1))
            fi
          fi
        fi
      fi
    elif [[ "$char" == "." ]]; then
      if [[ $count -ge $size ]]; then
        ((idx++))
        break
      fi
      count=0
    fi
    ((idx++))
  done <<< "$record"
  if [[ "$sizes" != *,* ]] && [[ $count -ge $size ]]; then
    :
    echo "$record"
    echo "SOLUTIONS: " $((count-size+1))
  fi
}

while read record sizes; do
  descend $record $sizes 0

  break
done < "$FILE"
