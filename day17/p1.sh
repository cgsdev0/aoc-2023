#!/bin/bash

clear
FILE=input.txt

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
# for each vertex v in Graph.Vertices:
#     dist[v] ← INFINITY
#     prev[v] ← UNDEFINED
#     add v to Q
for d in H V; do
  for ((r=0; r<size; r++)); do
    for ((c=0; c<size; c++)); do
      v="$d,$r,$c"
      qmap[$v]=1
      dist[$v]=1000000000
      queue+=("$v")
    done
  done
done
# dist[source] ← 0
dist["H,0,0"]=0
dist["V,0,0"]=0

# while Q is not empty:
while [[ ${#queue[@]} -gt 0 ]]; do
#     u ← vertex in Q with min dist[u]
#     remove u from Q
  # AKA pop from queue
  qlen=${#queue[@]}
  min=10000000000
  idx=-1
  for ((i=0; i<qlen; i++)); do
    qi=${queue[$i]}
    qdist=${dist["$qi"]}
    if [[ $qdist -lt $min ]]; then
      min=$qdist
      idx=$i
    fi
  done
  u=${queue[$idx]}
  qmap[$u]=
  queue=( "${queue[@]:0:idx}" "${queue[@]:((idx+1))}" )

  IFS=, read ul ur uc <<< "$u"
  for v in \
    "H,$((ur-1)),$uc,U" \
    "H,$((ur-2)),$uc,U" \
    "H,$((ur-3)),$uc,U" \
    "H,$((ur+1)),$uc,D" \
    "H,$((ur+2)),$uc,D" \
    "H,$((ur+3)),$uc,D" \
    "V,$ur,$((uc-1)),L" \
    "V,$ur,$((uc-2)),L" \
    "V,$ur,$((uc-3)),L" \
    "V,$ur,$((uc+1)),R" \
    "V,$ur,$((uc+2)),R" \
    "V,$ur,$((uc+3)),R"; \
  do
    IFS=, read vl vr vc d <<< "$v"
    v=$vl,$vr,$vc
    if [[ -z "${qmap[$v]}" ]]; then
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

for layer in V H; do
  # return dist[], prev[]
  declare -a sequence
  sequence=()
  # u ← target
  u=$layer,$((size-1)),$((size-1))
  # if prev[u] is defined or u = source:
  if [[ ! -z ${prev[$u]} ]] || [[ $u == *",0,0" ]]; then
  #     while u is defined:
    while [[ ! -z "$u" ]]; do
  #         insert u at the beginning of S
      sequence=("$u" "${sequence[@]}")
  #         u ← prev[u]
      d=${prev[$u]##*,}
      u=${prev[$u]%,*}
      # echo "$u $d"
    done
  fi

  curr=$layer,0,0
  counter=0
  for cell in "${sequence[@]:1}"; do
    IFS=, read ul ur uc <<< "$curr"
    IFS=, read vl vr vc <<< "$cell"
    compute_cost $ur $uc $vr $vc
    ((counter+=cost))
    curr=$cell
  done
  echo "$counter"
done
