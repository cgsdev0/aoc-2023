#!/bin/bash

DAY=$1
DIR=day$1
YEAR=2024

cd ~/aoc
mkdir -p "$YEAR/$DIR"
cd "$YEAR/$DIR"

start_part_2() {
  fetch_examples
  tmux next-window
  tmux select-pane -t right
  tmux send-keys C-c
  tmux send-keys "~/aoc/test-runner $YEAR $DAY 2" Enter
  tmux select-pane -t left
}

start_part_2
exit 0

touch p1.sh p2.sh
chmod +x p1.sh p2.sh

cat <<-EOF | tee p1.sh > p2.sh
#!/bin/bash

FILE="$1"

clear

cat "\$FILE"
EOF

curl -Ss "https://adventofcode.com/$YEAR/day/$DAY/input" \
        -H "cookie: session=$(cat ~/.aoc)" > input.txt

fetch_examples() {
  local INDEX=1
  while IFS= read -r line; do
    printf "\n\n\n%s" "$line" &> /dev/stderr
    EXAMPLE="$(echo "$line" | jq -r '.example')"
    SOLUTION="$(echo "$line" | jq -r '.solution')"
    printf "%s" "$EXAMPLE" > sample${INDEX}.txt
    printf "%s" "$SOLUTION" > solution${INDEX}.txt
    ((INDEX++))
  done < <(curl -Ss "https://adventofcode.com/$YEAR/day/$DAY" \
    -H "cookie: session=$(cat ~/.aoc)" \
    | pup 'article' | ~/aoc/claude | tee /dev/stderr | jq -r '.content[0].text' | jq -rc '.[]')
}
fetch_examples

tmux new-window
tmux send-keys "cd ~/aoc/$YEAR/$DIR; vim p1.sh p2.sh" Enter
tmux split-window -h
tmux send-keys "cd ~/aoc/$YEAR/$DIR" Enter
tmux send-keys "~/aoc/test-runner $YEAR $DAY" Enter

read -n 1 -s -r -p "Press any key to begin part 2"

start_part_2
