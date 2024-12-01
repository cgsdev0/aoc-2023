#!/bin/bash

DAY=$1
DIR=day$1
YEAR=2024

cd ~/aoc
mkdir -p "$YEAR/$DIR"
cd "$YEAR/$DIR"

touch p1.sh p2.sh
chmod +x p1.sh p2.sh

cat <<-EOF | tee p1.sh > p2.sh
#!/bin/bash

FILE="$1"

clear

cat "\$FILE"
EOF

curl "https://adventofcode.com/$YEAR/day/$DAY/input" \
        -H "cookie: session=$(cat ~/.aoc)" > input.txt

INDEX=1
while IFS= read -r line; do
  printf "\n\n\n%s" "$line" &> /dev/stderr
  EXAMPLE="$(echo "$line" | jq -r '.example')"
  SOLUTION="$(echo "$line" | jq -r '.solution')"
  printf "%s" "$EXAMPLE" > sample${INDEX}.txt
  printf "%s" "$SOLUTION" > solution${INDEX}.txt
  ((INDEX++))
done < <(curl -Ss "https://adventofcode.com/$YEAR/day/$DAY" | pup 'article' | ~/aoc/claude | tee /dev/stderr | jq -r '.content[0].text' | jq -rc '.[]')

tmux new-window
tmux send-keys "cd ~/aoc/$YEAR/$DIR; vim p1.sh" Enter
tmux split-window -h
tmux send-keys "cd ~/aoc/$YEAR/$DIR" Enter
tmux send-keys "~/aoc/test-runner $YEAR $DAY" Enter
