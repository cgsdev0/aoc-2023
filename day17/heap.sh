#!/bin/bash


# Example usage
enqueue 1,1,1,3
enqueue 2,2,2,1
enqueue 3,3,3,4
enqueue 4,4,4,1
enqueue 5,5,5,5

decrease_priority 5,5,5 0
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
dequeue
echo "${priority_queue[@]}"
