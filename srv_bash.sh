#!/bin/bash
echo  "CLEAR"
echo "POS, 40 / 40 /// Hello ! "
echo "PLINE, #888, #888, 10, 0 / 50, 200 / 50"
echo "END"

sleep 3
while :; do 
  echo "CLEAR"
  echo "RECT, #CCC, #CCC, 0, 0 / 0, 200 / 100"
  echo "POS, 10 / 15 /// Date: $(date | awk ' {printf $4}')"
  echo "POS, 10 / 30 /// ls: $(ls -1 | wc -l)"
  echo "PLINE, #888, #888, 10, 0/50, 200/50, 200/60, 0/60"
  echo "END"
  sleep 1
done
