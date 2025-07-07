#!/usr/bin/env bash
default="default"                               # session name


# Attach if session exists but not attatched to
if tmux has-session -t default 2>/dev/null && ! tmux list-clients -t default | grep -q .; then
    tmux attach -t default
    exit
fi

if tmux list-clients -t default | grep -q .; then
    echo Tmux is open on another client
    exit
fi

# Set-up from scratch
tmux new-session  -d  -s "$default"             # window 0, pane 0
tmux send-keys    -t "$default":0.0 "jtm" C-m

tmux split-window -h  -t "$default":0.0         # pane 1 (right)
tmux split-window -v -b -t "$default":0.1       # pane 2 (above pane 1)

tmux send-keys    -t "$default":0.1 "fastfetch" C-m
tmux send-keys    -t "$default":0.2 "pipes-rs" C-m

tmux attach       -t "$default"
