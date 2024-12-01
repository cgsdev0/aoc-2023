#!/bin/bash

clear

FILE=input.txt

paste -d'-' \
  <(tr -s ' ' < "$FILE" | cut -d' ' -f1 | sort -n) \
  <(tr -s ' ' < "$FILE" | cut -d' ' -f2 | sort -n) \
  | bc \
  | tr -d '-' \
  | paste -sd+ \
  | bc
