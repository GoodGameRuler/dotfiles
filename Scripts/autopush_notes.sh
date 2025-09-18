#!/bin/bash

folders=("$HOME/Notes" "$HOME/OrgNotes")
AUTOPUSH_MSG="[AUTOPUSH] Found unchecked changes on shutdown"

for dir in "${folders[@]}"; do
    if [ -d "$dir/.git" ]; then
        cd "$dir" || continue
        if [ -n "$(git status --porcelain)" ]; then
            echo "$AUTOPUSH_MSG in $dir"
            git add -A
            git commit -m "$AUTOPUSH_MSG"
            git push
        fi
    fi
done

