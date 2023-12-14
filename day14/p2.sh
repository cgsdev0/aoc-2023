#!/bin/bash

clear

FILE=input.txt

declare -A grid
row=0
height=$(wc -l < $FILE | cut -d' ' -f2)
while IFS= read -r line; do
  if [[ $row -eq 0 ]]; then
    width=${#line}
  fi
  col=0
  while IFS= read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi
    grid["$row,$col"]=$char
    ((col++))
  done <<< "$line"
  ((row++))
done < $FILE

function idx() {
  local x y
  case "$gravity" in
    N)
      y=$1
      x=$2
      ;;
    S)
      y=$((height-$1-1))
      x=$2
      ;;
    W)
      x=$1
      y=$2
      ;;
    E)
      x=$((height-$1-1))
      y=$2
      ;;
  esac
  char=${grid["${y},${x}"]}
  if [[ "$char" != "#" ]]; then
    grid[${y},${x}]=$3
  fi
}

function load() {
  gravity=N
  total=0
  local x y
  for ((y=0; y<height; y++)); do
    for ((x=0; x<width; x++)); do
      local char2=${grid["${y},${x}"]}
      if [[ "$char2" == "O" ]]; then
        ((total+=height-y))
      fi
    done
  done
  echo $total
}


function visualize() {
  return
  clear
  for ((y=0; y<height; y++)); do
    for ((x=0; x<width; x++)); do
      printf "%s" ${grid["${y},${x}"]}
    done
    printf "\n"
  done
  load
  sleep 0.2
}
visualize

gravity=N
function apply_gravity() {
  local -a indices
  for ((y=0; y<height; y++)); do
    if [[ $y -eq 0 ]]; then
      for ((i=0; i<width; i++)); do
        indices[$i]=0
      done
    fi
    for ((x=0; x<width; x++)); do
      idx $y $x "."
      if [[ "$char" == "O" ]]; then
        i=${indices[x]}
        ((indices[$x]++))
        idx $i $x "O"
      elif [[ "$char" == "#" ]]; then
        indices[$x]=$((y + 1))
      fi
    done
  done
}

function spin_cycle() {
  gravity=N
  apply_gravity
  visualize
  gravity=W
  apply_gravity
  visualize
  gravity=S
  apply_gravity
  visualize
  gravity=E
  apply_gravity
  visualize
  load
}
for ((iter=0; iter<1000; iter++)); do
  spin_cycle
done
