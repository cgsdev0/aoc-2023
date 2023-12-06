#!/bin/bash

clear

FILE=input.txt

function calculate() {
  read time
  read distance
  seq 0 $time \
    | awk '{ print "(('$time'-"$0")*"$0")>'$distance'"; }' \
    | bc \
    | grep '^1$' -c
}

calculate < <(cat $FILE \
  | cut -d' ' -f2- \
  | tr -d ' ')
