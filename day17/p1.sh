#!/bin/bash

clear
FILE=sample.txt

declare -a grid
while read -r line; do
  grid+=($line)
done < $FILE

size=$(wc -l < $FILE | cut -d' ' -f2)
# row=${grid[1]}
# echo "${row:1:1}"
declare -A dist
declare -A prev
declare -a queue
declare -A qmap

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

enqueue 0,0,0
declare -A cameFrom
declare -A gScore
for ((r=0; r<size; r++)); do
  for ((c=0; c<size; c++)); do
    v="$r,$c"
    if [[ $r -eq 0 ]] && [[ $c -eq 0 ]]; then
      dist[$v]=0
    else
      dist[$v]=1000000000
    fi
    enqueue "$v",${dist[$v]}
  done
done

target=$((size-1)),$((size-1))
# while Q is not empty:
while [[ ${#priority_queue[@]} -gt 0 ]]; do
#     u ← vertex in Q with min dist[u]
#     remove u from Q
  # AKA pop from queue
  dequeue
  u=$front
  qmap[$u]=
  if [[ -z ${qmap[$target]} ]]; then
    echo "DONE"
    break
  fi

  IFS=, read ur uc <<< "$u"
  for v in \
    "$((ur-1)),$uc,U" \
    "$((ur+1)),$uc,D" \
    "$ur,$((uc-1)),L" \
    "$ur,$((uc+1)),R"; \
  do
    IFS=, read vr vc d <<< "$v"
    v=$vr,$vc
    if [[ -z "${qmap[$v]}" ]]; then
      continue
    fi
    udist=${dist[$u]}
    alt=$udist
    cost=${grid[$vr]:$vc:1}
    ((alt+=cost))
    # if [[ $d == $d1 ]]; then
    #   continue
    # fi
    # if [[ $d == "U" ]] && [[ $d1 == "D" ]]; then
    #   continue
    # fi
    # if [[ $d == "D" ]] && [[ $d1 == "U" ]]; then
    #   continue
    # fi
    # if [[ $d == "R" ]] && [[ $d1 == "L" ]]; then
    #   continue
    # fi
    # if [[ $d == "L" ]] && [[ $d1 == "R" ]]; then
    #   continue
    # fi

    if [[ $alt -lt ${dist[$v]} ]]; then
      dist[$v]=$alt
      prev[$v]=$u,$d
      decrease_priority $v $alt
    fi
  done
done

declare -a sequence
sequence=()
# u ← target
u=$target
# if prev[u] is defined or u = source:
if [[ ! -z ${prev[$u]} ]] || [[ $u == "0,0" ]]; then
#     while u is defined:
  while [[ ! -z "$u" ]]; do
#         insert u at the beginning of S
    sequence=("$u" "${sequence[@]}")
#         u ← prev[u]
    d=${prev[$u]##*,}
    u=${prev[$u]%,*}
    echo "$u $d"
  done
fi

counter=0
for cell in "${sequence[@]:1}"; do
  IFS=, read vr vc <<< "$cell"
  cost=${grid[$vr]:$vc:1}
  ((counter+=cost))
done
echo "$counter"
