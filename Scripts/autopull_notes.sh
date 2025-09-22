#!/bin/bash

folders=("$HOME/Notes" "$HOME/OrgNotes")
AUTOPULL_MSG="[AUTOPULL] Pulling latest changes on startup"

for dir in "${folders[@]}"; do
    if [ -d "$dir/.git" ]; then
        cd "$dir" || continue
        echo "$AUTOPULL_MSG in $dir"

        # Make sure repo is clean enough to pull
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo "Skipping $dir: uncommitted changes present"
            continue
        fi

        # Fetch first
        if ! git fetch --all; then
            echo "Fetch failed in $dir, skipping"
            continue
        fi

        # Try pull with rebase
        if ! git pull --rebase --autostash; then
            echo "Pull failed in $dir, attempting to abort rebase/merge"
            git rebase --abort 2>/dev/null || git merge --abort 2>/dev/null
            continue
        fi

        echo "Successfully pulled in $dir"
    fi
done
