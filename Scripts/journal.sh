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

ADMIN=admin

function jtm() {
    local arg_date=""
    local next=false
    local prev=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--date)
                arg_date="$2"
                shift 2
                ;;
            -n|--next)
                next=true
                shift
                ;;
            -p|--prev)
                prev=true
                shift
                ;;
            *)
                echo "Usage: jtm [-n|--next] [-p|--prev] [-d|--date YYYY-MM-DD]"
                return 1
                ;;
        esac
    done

    local ref_date=${arg_date:-$(date +%Y-%m-%d)}

    if $next; then
        ref_date=$(date -d "$ref_date +1 day" +%Y-%m-%d)
    elif $prev; then
        ref_date=$(date -d "$ref_date -1 day" +%Y-%m-%d)
    fi

    mkdir -p "$CACHE"
    ( git -C "$NOTES" pull >> "$CACHE/git_log" 2>&1 & )

    local file="$NOTES/journal/$ADMIN/daily/$ref_date.md"
    if [[ ! -f $file ]]; then
        nvim -c "0r $NOTES/journal/$ADMIN/daily/template.md" "$file"
    else
        nvim "$file"
    fi
}

function jtw() {
    local arg_date=""
    local next=false
    local prev=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--date)
                arg_date="$2"
                shift 2
                ;;
            -n|--next)
                next=true
                shift
                ;;
            -p|--prev)
                prev=true
                shift
                ;;
            *)
                echo "Usage: jtw [-n|--next] [-p|--prev] [-d|--date YYYY-MM-DD]"
                return 1
                ;;
        esac
    done

    local ref_date=${arg_date:-$(date +%Y-%m-%d)}
    # local sunday=$(date -d "$ref_date last sunday" +%Y-%m-%d)
    #
    # Convert ref_date to weekday number: Monday=1 ... Sunday=7
    local weekday=$(date -d "$ref_date" +%u)

    # Subtract weekday days (so Sunday->7, Monday->1, ...) to go to last Sunday
    local sunday=$(date -d "$ref_date -$weekday days" +%Y-%m-%d)

    if $next; then
        sunday=$(date -d "$sunday +7 days" +%Y-%m-%d)
    elif $prev; then
        sunday=$(date -d "$sunday -7 days" +%Y-%m-%d)
    fi

    mkdir -p "$CACHE"
    ( git -C "$NOTES" pull >> "$CACHE/git_log" 2>&1 & )

    local file="$NOTES/journal/$ADMIN/weekly/$sunday.md"
    if [[ ! -f $file ]]; then
        nvim -c "0r $NOTES/journal/$ADMIN/weekly/template.md" "$file"
    else
        nvim "$file"
    fi
}

alias jtg='rg --color=always --line-number --no-heading --smart-case "${*:-}" "$NOTES/journal" \
  | fzf --ansi --delimiter : \
        --preview "bat --color=always {1} --highlight-line {2}" \
        --bind "enter:become(nvim {1} +{2})"'
