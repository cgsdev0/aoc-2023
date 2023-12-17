#!/bin/bash

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
        FOUND=true
        break
      fi
    done
    if [[ ! -z $FOUND ]]; then
      heapify_up
    else
      enqueue $key,$priority
    fi
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
    echo "$front"
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

# Example usage
enqueue A,3
enqueue B,1
enqueue C,4
enqueue D,1
enqueue E,5

decrease_priority E 0
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
enqueue G,9
echo "${priority_queue[@]}"
dequeue
decrease_priority G 0
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
