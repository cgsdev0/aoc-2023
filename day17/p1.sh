#!/bin/bash

clear
FILE=sample.txt

declare -a grid
while read -r line; do
  grid+=($line)
done < $FILE

declare -a priority_queue

enqueue() {
    local value=$1
    priority_queue+=("$value")
    heapify_up
}

decrease_priority() {
    local key=$1
    local priority=$2
    local size=${#priority_queue[@]}
    for ((i=0; i<size; i++)); do
      if [[ ${priority_queue[i]%,*} == $key ]]; then
        priority_queue[$i]=$key,$priority
        break
      fi
    done
    heapify_up
}

dequeue() {
    local size=${#priority_queue[@]}
    if [ $size -eq 0 ]; then
        echo "Priority queue is empty"
        return 1
    fi

    front=${priority_queue[0]%,*}
    priority_queue=("${priority_queue[@]:1}")
    heapify_down
}

heapify_up() {
    local index=$(( ${#priority_queue[@]} - 1 ))

    while [ $index -gt 0 ]; do
        local parent_index=$(( ($index - 1) / 2 ))
        parent="${priority_queue[$parent_index]##*,}"
        self="${priority_queue[$index]##*,}"
        if [ $self -lt $parent ]; then
            # Swap elements if the current element is smaller than its parent
            local temp=${priority_queue[$index]}
            priority_queue[$index]=${priority_queue[$parent_index]}
            priority_queue[$parent_index]=$temp

            index=$parent_index
        else
            break
        fi
    done
}

heapify_down() {
  local index=0
  local size=${#priority_queue[@]}

  while true; do
      local left_idx=$((2 * index + 1))
      local right_idx=$((2 * index + 2))
      local smallest_idx=$index

      local left="${priority_queue[$left_idx]##*,}"
      local smallest="${priority_queue[$smallest_idx]##*,}"
      local right="${priority_queue[$right_idx]##*,}"

      if [ "$left_idx" -lt "$size" ] && [ $left -lt $smallest ]; then
          smallest_idx=$left_idx
      fi
      if [ "$right_idx" -lt "$size" ] && [ $right -lt $smallest ]; then
          smallest_idx=$right_idx
      fi

      if [ "$smallest_idx" -ne "$index" ]; then
          # Swap elements if the current element is greater than the smallest_idx child
          local temp=${priority_queue[$index]}
          priority_queue[$index]=${priority_queue[$smallest_idx]}
          priority_queue[$smallest_idx]=$temp

          index=$smallest_idx
      else
          break
      fi
  done
}

size=$(wc -l < $FILE | cut -d' ' -f2)
target=$((size-1)),$((size-1))
# row=${grid[1]}
# echo "${row:1:1}"
declare -A dist
declare -A prev
declare -a queue
declare -A qmap

function compute_cost() {
  local ur=$1
  local uc=$2
  local vr=$3
  local vc=$4
  # echo -n "COST FROM $ur,$uc -> $vr,$vc: "
  dr=$((vr-ur))
  dc=$((vc-uc))
  if [[ $dr -gt 0 ]]; then
    ((dr/=dr))
  fi
  if [[ $dr -lt 0 ]]; then
    ((dr/=-dr))
  fi
  if [[ $dc -gt 0 ]]; then
    ((dc/=dc))
  fi
  if [[ $dc -lt 0 ]]; then
    ((dc/=-dc))
  fi
  cost=0
  while [[ $vr -ne $ur ]] || [[ $vc -ne $uc ]]; do
    dist=${grid[$vr]:$vc:1}
    ((cost+=dist))
    ((vr-=dr))
    ((vc-=dc))
  done
  # echo "$cost"
}

  IFS=, read ul ur uc <<< "$u"
  for v in \
    "H,$((ur-4)),$uc,U" \
    "H,$((ur-5)),$uc,U" \
    "H,$((ur-6)),$uc,U" \
    "H,$((ur-7)),$uc,U" \
    "H,$((ur-8)),$uc,U" \
    "H,$((ur-9)),$uc,U" \
    "H,$((ur-10)),$uc,U" \
    "H,$((ur+4)),$uc,D" \
    "H,$((ur+5)),$uc,D" \
    "H,$((ur+6)),$uc,D" \
    "H,$((ur+7)),$uc,D" \
    "H,$((ur+8)),$uc,D" \
    "H,$((ur+9)),$uc,D" \
    "H,$((ur+10)),$uc,D" \
    "V,$ur,$((uc-4)),L" \
    "V,$ur,$((uc-5)),L" \
    "V,$ur,$((uc-6)),L" \
    "V,$ur,$((uc-7)),L" \
    "V,$ur,$((uc-8)),L" \
    "V,$ur,$((uc-9)),L" \
    "V,$ur,$((uc-10)),L" \
    "V,$ur,$((uc+4)),R" \
    "V,$ur,$((uc+5)),R" \
    "V,$ur,$((uc+6)),R" \
    "V,$ur,$((uc+7)),R" \
    "V,$ur,$((uc+8)),R" \
    "V,$ur,$((uc+9)),R" \
    "V,$ur,$((uc+10)),R"; \
  do
    IFS=, read vl vr vc d <<< "$v"
    v=$vl,$vr,$vc
    if [[ $vr -lt 0 ]] || [[ $vc -lt 0 ]]; then
      continue
    fi
    if [[ $vr -ge $size ]] || [[ $vc -ge $size ]]; then
      continue
    fi
    udist=${dist[$u]}
    alt=$udist
    compute_cost $ur $uc $vr $vc
    ((alt+=cost))

    lookback1=${prev[$u]}
    l1=${lookback1%,*}
    d1=${lookback1##*,}
    if [[ $d == $d1 ]]; then
      continue
    fi
    if [[ $d == "U" ]] && [[ $d1 == "D" ]]; then
      continue
    fi
    if [[ $d == "D" ]] && [[ $d1 == "U" ]]; then
      continue
    fi
    if [[ $d == "R" ]] && [[ $d1 == "L" ]]; then
      continue
    fi
    if [[ $d == "L" ]] && [[ $d1 == "R" ]]; then
      continue
    fi

    if [[ $alt -lt ${dist[$v]} ]]; then
      dist[$v]=$alt
      prev[$v]=$u,$d
    fi
  done
done

enqueue 0,0,0
declare -A cameFrom
declare -A gScore
for layer in V H; do
  for ((r=0; r<size; r++)); do
    for ((c=0; c<size; c++)); do
      v="$layer,$r,$c"
      if [[ $r -eq 0 ]] && [[ $c -eq 0 ]]; then
        dist[$v]=0
      else
        dist[$v]=1000000000
      fi
      enqueue "$v",${dist[$v]}
    done
  done
done
