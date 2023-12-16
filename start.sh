#!/bin/bash

DAY=$1
DIR=day$1

cd ~/aoc
mkdir -p $DIR
cd $DIR

touch sample.txt input.txt
touch p1.sh p2.sh
chmod +x p1.sh p2.sh

cat <<-EOF | tee p1.sh > p2.sh
#!/bin/bash

clear
EOF

tmux new-window
tmux send-keys "cd ~/aoc/$DIR; vim p1.sh" Enter
tmux split-window -h
tmux send-keys "cd ~/aoc/$DIR" Enter
tmux send-keys "watch-and-reload ./p1.sh sample.txt input.txt" Enter
