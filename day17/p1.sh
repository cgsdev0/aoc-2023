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
# for each vertex v in Graph.Vertices:
#     dist[v] ← INFINITY
#     prev[v] ← UNDEFINED
#     add v to Q
for ((r=0; r<size; r++)); do
  for ((c=0; c<size; c++)); do
    v="$r,$c"
    qmap[$v]=1
    dist[$v]=1000000000
    queue+=("$v")
  done
done
# dist[source] ← 0
dist["0,0"]=0

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

  IFS=, read ur uc <<< "$u"
  for v in "$((ur-1)),$uc,U" "$((ur+1)),$uc,D" "$ur,$((uc-1)),L" "$ur,$((uc+1)),R"; do
    IFS=, read vr vc d <<< "$v"
    v=$vr,$vc
    udist=${dist[$u]}
    vdist=${grid[$vr]:$vc:1}
    alt=$((udist+vdist))

    lookback1=${prev[$u]}
    l1=${lookback1%,*}
    d1=${lookback1##*,}
    if [[ ! -z $l1 ]]; then
      lookback2=${prev["$l1"]}
      l2=${lookback2%,*}
      d2=${lookback2##*,}
      if [[ ! -z $l2 ]]; then
        lookback3=${prev["$l2"]}
        l3=${lookback3%,*}
        d3=${lookback3##*,}
        if [[ $d == $d3 ]] && [[ $d3 == $d2 ]] && [[ $d2 == $d1 ]]; then
          echo "SKIPPING $v $d"
          continue
        fi
      fi
    fi
    if [[ alt -lt ${dist[$v]} ]]; then
      dist[$v]=$alt
      prev[$v]=$u,$d
    fi
  done
done
# return dist[], prev[]
declare -a sequence
# u ← target
u=$((size-1)),$((size-1))
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

for cell in "${sequence[@]:1}"; do
  IFS=, read r c <<< "$cell"
  echo ${grid[$r]:$c:1}
done \
  | paste -sd+ \
  | bc
