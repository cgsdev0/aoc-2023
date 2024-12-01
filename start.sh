#!/bin/bash

DAY=$1
DIR=test$1
YEAR=2023

cd ~/aoc
mkdir -p $DIR
cd $DIR

touch p1.sh p2.sh
chmod +x p1.sh p2.sh

cat <<-EOF | tee p1.sh > p2.sh
#!/bin/bash

clear
EOF

curl "https://adventofcode.com/$YEAR/day/$DAY/input" \
        -H "cookie: session=$(cat ~/.aoc)" > input.txt

INDEX=1
while IFS= read -r line; do
  EXAMPLE="$(echo "$line" | jq '.example')"
  SOLUTION="$(echo "$solution" | jq '.solution')"
  printf "%s" "$EXAMPLE" > sample${INDEX}.txt
  printf "%s" "$SOLUTION" > solution${INDEX}.txt
  ((INDEX++))
done < <(curl -Ss "https://adventofcode.com/$YEAR/day/$DAY" | pup 'article' | ~/aoc/claude | jq -r '.content[0].text' | jq -rc '.[]')

tmux new-window
tmux send-keys "cd ~/aoc/$YEAR/$DIR; vim p1.sh" Enter
tmux split-window -h
tmux send-keys "cd ~/aoc/$YEAR/$DIR" Enter
tmux send-keys "watch-and-reload ./p1.sh sample*.txt input.txt" Enter

