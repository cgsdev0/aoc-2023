#!/bin/bash

clear
FILE=sample.txt

function matrix() {
  local -a px py pz vx vy vz cx cy cz
  while IFS=, read ipx ipy ipz ivx ivy ivz; do
    px+=("$ipx")
    py+=("$ipy")
    pz+=("$ipz")
    vx+=("$ivx")
    vy+=("$ivy")
    vz+=("$ivz")
  done

  cx[0]=$(( py[1]*vz[1]-vy[1]*pz[1] - (py[0]*vz[0]-vy[0]*pz[0]) ))
  cy[0]=$(( pz[1]*vx[1]-vx[1]*pz[1] - (pz[0]*vz[0]-vx[0]*pz[0]) ))
  cz[0]=$(( px[1]*vy[1]-vy[1]*px[1] - (px[0]*vy[0]-vy[0]*px[0]) ))
  cx[1]=$(( py[2]*vz[2]-vy[2]*pz[2] - (py[0]*vz[0]-vy[0]*pz[0]) ))
  cy[1]=$(( pz[2]*vx[2]-vx[2]*pz[2] - (pz[0]*vz[0]-vx[0]*pz[0]) ))
  cz[1]=$(( px[2]*vy[2]-vy[2]*px[2] - (px[0]*vy[0]-vy[0]*px[0]) ))
  echo -n $((vy[1]-vy[0])) $((vx[0]-vx[1])) 0" "
  echo -n $((vy[2]-vy[0])) $((vx[0]-vx[2])) 0" "
  echo ${cz[0]}
  echo -n 0 $((pz[0]-pz[1])) $((py[1]-py[0]))" "
  echo -n 0 $((pz[0]-pz[2])) $((py[2]-py[0]))" "
  echo ${cx[1]}
  echo -n $((vz[0]-vz[1])) 0 $((vx[1]-vx[0]))" "
  echo -n $((vz[0]-vz[2])) 0 $((vx[2]-vx[0]))" "
  echo ${cy[0]}
  echo -n $((pz[1]-pz[0])) 0 $((px[0]-px[1]))" "
  echo -n $((pz[2]-pz[0])) 0 $((px[0]-px[2]))" "
  echo ${cy[1]}
  echo -n $((py[0]-py[1])) $((px[1]-px[0])) 0" "
  echo -n $((py[0]-py[2])) $((px[2]-px[0])) 0" "
  echo ${cz[1]}
  echo -n 0 $((vz[1]-vz[0])) $((vy[0]-vy[1]))" "
  echo -n 0 $((vz[2]-vz[0])) $((vy[0]-vy[2]))" "
  echo ${cx[0]}
  # echo 0 $((vz[1]-vz[0])) $((vy[0]-vy[1]))
  # echo $((vz[0]-vz[1])) 0 $((vx[1]-vx[0]))
  # echo $((vy[1]-vy[0])) $((vx[0]-vx[1])) 0
  # echo
  # echo 0 $((vz[2]-vz[0])) $((vy[0]-vy[2]))
  # echo $((vz[0]-vz[2])) 0 $((vx[2]-vx[0]))
  # echo $((vy[2]-vy[0])) $((vx[0]-vx[2])) 0
  # echo
  # echo 0 $((pz[0]-pz[1])) $((py[1]-py[0]))
  # echo $((pz[1]-pz[0])) 0 $((px[0]-px[1]))
  # echo $((py[0]-py[1])) $((px[1]-px[0])) 0
  # echo
  # echo 0 $((pz[0]-pz[2])) $((py[2]-py[0]))
  # echo $((pz[2]-pz[0])) 0 $((px[0]-px[2]))
  # echo $((py[0]-py[2])) $((px[2]-px[0])) 0
}

function add_row() {
    local multiple=$1
    local source=$2
    local dest=$3
    local i
    for ((i=0;i<7;i++)); do
      grid["$dest,$i"]=$(echo "scale=2; ${grid["$dest,$i"]} + ${grid["$source,$i"]}*$multiple" | bc)
    done
}

declare -A grid
function echelon() {
  row=0
  while read a b c d e f g; do
    grid["$row,0"]=$((a * 1))
    grid["$row,1"]=$((b * 1))
    grid["$row,2"]=$((c * 1))
    grid["$row,3"]=$((d * 1))
    grid["$row,4"]=$((e * 1))
    grid["$row,5"]=$((f * 1))
    grid["$row,6"]=$((g * 1))
    ((row++))
  done
  for ((col=0; col<1; col++)); do
    for((i=col+1;i<6;i++)); do
      add_row $(echo "scale=2; ${grid["$i,$((col+1))"]} / ${grid["$col,$col"]}" | bc) $col $i
    done
  done
  for((row=0;row<6;row++)); do
    for((col=0;col<7;col++)); do
      echo -n ${grid["$row,$col"]}" "
    done
    echo
  done
}
head -n3 $FILE \
  | tr '@' ',' \
  | tr -d ' ' \
  | matrix \
  | echelon
