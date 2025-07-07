# alias nts='rg --color=always --line-number --no-heading --smart-case "${*:-}" ~/OrgNotes | fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : --preview "bat --color=always {1} --highlight-line {2}" --bind "enter:become(nvim {1} +{2})"'
# Mornings Journal
# alias jtms='rg --files --glob "*.md" ~/OrgNotes/journal/mornings | fzf --preview "bat --style=numbers --color=always {}" --height 40% --reverse'
# alias jtml='nvim "$(ls ~/OrgNotes/journal/mornings/*.md | fzf --preview "bat --style=numbers --color=always ~/OrgNotes/journal/mornings/{}" --height 40% --reverse)"'

# Evenings Journal
# alias jtn='FILE=~/OrgNotes/journal/evenings/$(date +%Y-%m-%d).md; if [[ ! -f $FILE ]]; then cp ~/OrgNotes/journal/evenings/template.md "$FILE"; fi; nvim "$FILE"'
# alias jtns='rg --files --glob "*.md" ~/OrgNotes/journal/evenings | fzf --preview "bat --style=numbers --color=always {}" --height 40% --reverse'
# alias jtnl='nvim "$(ls ~/OrgNotes/journal/evenings/*.md | fzf --preview "bat --style=numbers --color=always ~/OrgNotes/journal/mornings/{}" --height 40% --reverse)"'

NOTES=/home/udit/OrgNotes
CACHE=/home/udit/.cache/jtm

ADMIN=/admin

function jtm() {
    mkdir -p $CACHE
    ( git -C "$NOTES" pull >> "$CACHE/git_log" 2>&1 & )
    FILE="$NOTES/journal/$ADMIN/$(date +%Y-%m-%d).md";
    if [[ ! -f $FILE ]]; then 
        cp "$NOTES/journal/$ADMIN/template.md" "$FILE"
    fi
    nvim "$FILE"
}
