#!/bin/bash

set -o noglob


FILE=input.txt

function printl() {
  local indent=$1
  printf "%*s" $indent "" 1>&2
  shift
  printf "%s\n" "$*" 1>&2
}


declare -A cache

function descend() {
  local record="$1"
  local sizes="$2"
  local iter="$3"
  local sliced="$4"

  if [[ $iter -eq 0 ]]; then
    local left=${record//[^#]/}
    if [[ ${#left} -eq 0 ]]; then
      # printl 0 "------------"
      ((counter++))
    fi
    return
  fi


  local key="$record $sizes"
  if [[ ! -z "${cache[$key]}" ]]; then
    local cached=${cache[$key]}
    ((counter+=cached))
    # printl 0 "cache hit $key"
    return
  fi


  local counter_before=$counter
  # pop size from sizes
  local size="${sizes%%,*}"
  sizes="${sizes#*,}"

  if [[ -z "$record" ]]; then
    return
  fi
  # printl $sliced $record $size "depth:$iter"

  local cost=${sizes//[,]/+}
  cost=$((cost))

  local idx=0
  local char
  while read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi

    local remainder=${record:idx}
    local budget="${remainder//[^#?]/}"
    budget=${#budget}
    if [[ $budget -lt cost ]]; then
      break
    fi

    local slice="${record:idx:size}"
    if [[ ${#slice} -lt $size ]]; then
      break
    fi
    if [[ ${slice:0:1} == "." ]]; then
      ((idx++))
      continue
    fi
    # printl 0 "$iter --> $slice"
    group=${slice//[^?#]/}
    if [[ ${#group} -lt $size ]]; then
      if [[ "${slice:0:1}" == "#" ]]; then
        break
      fi
      ((idx++))
      continue
    fi
    local peek="${record:((idx+size)):1}"
    if [[ "$peek" != "#" ]]; then
      local descendant="${record:((idx+size+1))}"
      descend "$descendant" "${sizes:-0}" "$((iter-1))" "$((sliced+idx+size+1))"
    fi
    # check if we hit obsidian
    if [[ "${slice:0:1}" == "#" ]]; then
      break
    fi
    # wtf was the point of this? idk
    # check if we hit air
    # if [[ "${record:((idx+size)):1}" == "." ]]; then
    #   return
    # fi
    ((idx++))
  done <<< "$record"

  local change=$((counter-counter_before))
  cache[$key]=$change
  # printl 0 "${#cache[@]} cache miss $key"
}

function main() {
  while read record sizes; do
    record=${record}?${record}?${record}?${record}?${record}
    sizes=${sizes},${sizes},${sizes},${sizes},${sizes}
    maxdepth=${sizes//[^,]/}
    maxdepth=${#maxdepth}
    ((maxdepth++))
    counter=0
    descend "$record" "$sizes" "$maxdepth" 0
    echo $counter
  done
}

if [[ ! -z "$DONT_FORK_BOMB_ME_BRO" ]]; then
  main
else
  export DONT_FORK_BOMB_ME_BRO=true
  <$FILE parallel --pipe -N 100 $0 \
    | paste -sd+ \
    | bc
fi
