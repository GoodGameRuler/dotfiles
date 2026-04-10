NOTES=/home/udit/OrgNotes
CACHE=/home/udit/.cache/jtm

ADMIN=admin

# -- Colours & output helpers ------------------------------------------------
_jt_red=$'\033[31m'
_jt_green=$'\033[32m'
_jt_yellow=$'\033[33m'
_jt_cyan=$'\033[36m'
_jt_bold=$'\033[1m'
_jt_dim=$'\033[2m'
_jt_reset=$'\033[0m'

function _jt_err()  { printf '%s\n' "${_jt_red}${_jt_bold}error:${_jt_reset} $*" >&2; }
function _jt_warn() { printf '%s\n' "${_jt_yellow}warning:${_jt_reset} $*" >&2; }
function _jt_info() { printf '%s\n' "${_jt_cyan}info:${_jt_reset} $*" >&2; }
function _jt_ok()   { printf '%s\n' "${_jt_green}${_jt_bold}✓${_jt_reset} $*" >&2; }

if [ -z "${EDITOR:-}" ]; then
    _jt_warn "\$EDITOR is not set — defaulting to ${_jt_bold}vi${_jt_reset}"
    EDITOR=vi
fi

# -- Suggest closest flag (prefix + substring matching) ----------------------
function _jt_suggest_flag() {
    local input="$1"
    shift
    local -a flags=("$@")
    local best=""

    # 1) Exact prefix match (e.g. --carry matches --carry-forward)
    for f in "${flags[@]}"; do
        if [[ "$f" == "$input"* && "$f" != "$input" ]]; then
            best="$f"
            break
        fi
    done

    # 2) Input is a substring of a flag (e.g. --forwrd ~ --carry-forward)
    if [[ -z "$best" ]]; then
        for f in "${flags[@]}"; do
            if [[ "$f" == *"$input"* && "$f" != "$input" ]]; then
                best="$f"
                break
            fi
        done
    fi

    # 3) Flag is a substring of input (e.g. --carry-forwards ~ --carry-forward)
    if [[ -z "$best" ]]; then
        for f in "${flags[@]}"; do
            # Only match if the flag is at least half the input length
            if (( ${#f} * 2 >= ${#input} )) && [[ "$input" == *"$f"* && "$f" != "$input" ]]; then
                best="$f"
                break
            fi
        done
    fi

    # 4) Strip dashes and compare for close matches (prefix sans dashes)
    if [[ -z "$best" ]]; then
        local stripped="${input//-/}"
        local slen=${#stripped}
        for f in "${flags[@]}"; do
            local fstripped="${f//-/}"
            local fslen=${#fstripped}
            # Require the shorter side to be at least half the longer
            local longer=$slen
            (( fslen > longer )) && longer=$fslen
            local shorter_s=$slen
            (( fslen < shorter_s )) && shorter_s=$fslen
            if (( shorter_s * 2 >= longer )) && [[ "$fstripped" == "$stripped"* || "$stripped" == "$fstripped"* ]]; then
                best="$f"
                break
            fi
        done
    fi

    # 5) Length-similar flags with mostly shared characters
    if [[ -z "$best" ]]; then
        local input_len=${#input}
        local best_score=0 best_len=0
        local f flen diff matches shorter k
        for f in "${flags[@]}"; do
            flen=${#f}
            diff=$((input_len - flen))
            (( diff < 0 )) && diff=$(( -diff ))
            (( diff > 3 )) && continue
            matches=0
            shorter=$input_len
            (( flen < shorter )) && shorter=$flen
            for (( k=0; k<shorter; k++ )); do
                [[ "${input:$k:1}" == "${f:$k:1}" ]] && (( matches++ ))
            done
            # Require >60% positional match; score by match count to prefer longer flags
            local score=$((matches * flen))
            if (( shorter > 0 && matches * 100 / shorter > 60 && score > best_score )); then
                best_score=$score
                best="$f"
            fi
        done
    fi

    if [[ -n "$best" ]]; then
        printf '%s\n' "    ${_jt_dim}did you mean ${_jt_reset}${_jt_bold}${best}${_jt_reset}${_jt_dim}?${_jt_reset}" >&2
    fi
}

# -- Help display -------------------------------------------------------------
function _jt_help() {
    local cmd="$1"
    local period="$2"

    printf '%s\n' "${_jt_bold}${cmd}${_jt_reset} — open ${period} journal in ${_jt_dim}\$EDITOR${_jt_reset} ${_jt_dim}(${EDITOR})${_jt_reset}"
    echo ""
    printf '%s\n' "${_jt_bold}USAGE${_jt_reset}"
    printf '%s\n' "    ${_jt_cyan}${cmd}${_jt_reset} [flags]"
    echo ""
    printf '%s\n' "${_jt_bold}FLAGS${_jt_reset}"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-h, --help"             "${_jt_reset}" "Show this help message"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-d, --date YYYY-MM-DD"  "${_jt_reset}" "Target a specific date ${_jt_dim}(default: today)${_jt_reset}"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-n, --next"             "${_jt_reset}" "Move forward one ${period}"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-p, --prev"             "${_jt_reset}" "Move back one ${period}"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-cf, --carry-forward"   "${_jt_reset}" "Carry incomplete tasks from previous ${period}"
    printf '  %s%-24s%s %s\n' "${_jt_green}" "-cfl, --carry-forward-latest" "${_jt_reset}" "Carry incomplete tasks from latest available entry"
    echo ""
    printf '%s\n' "${_jt_bold}EXAMPLES${_jt_reset}"
    printf '  %s\n' "${_jt_dim}${cmd}${_jt_reset}                           ${_jt_dim}# open today's / this ${period}'s journal${_jt_reset}"
    printf '  %s\n' "${_jt_dim}${cmd} -cf${_jt_reset}                       ${_jt_dim}# carry forward from yesterday / last ${period}${_jt_reset}"
    printf '  %s\n' "${_jt_dim}${cmd} -cfl -d 2026-01-15${_jt_reset}        ${_jt_dim}# carry latest into a specific date${_jt_reset}"
}

function _jtm_carry_forward() {
    local source_file="$1"
    local template_file="$2"

    [[ ! -f "$source_file" ]] && return

    # Extract default task names from the template to skip them
    local skip_names=""
    local re_top='^- \[.\] '
    local re_top_x='^- \[x\] '
    local re_sub_x='\[x\]'

    if [[ -f "$template_file" ]]; then
        local in_tmpl_tasks=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^##[[:space:]]+Tasks ]]; then
                in_tmpl_tasks=true
                continue
            fi
            if $in_tmpl_tasks && [[ "$line" =~ ^## ]]; then
                break
            fi
            if $in_tmpl_tasks && [[ "$line" =~ $re_top ]]; then
                local task_name="${line#*] }"
                skip_names+=$'\n'"$task_name"$'\n'
            fi
        done < "$template_file"
    fi

    local in_tasks=false
    local current_block=""
    local current_is_complete=false
    local current_is_skipped=false
    local result=""

    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]]+Tasks ]]; then
            in_tasks=true
            continue
        fi

        if $in_tasks && [[ "$line" =~ ^## ]]; then
            break
        fi

        if ! $in_tasks; then
            continue
        fi

        # Top-level task
        if [[ "$line" =~ $re_top ]]; then
            # Flush previous block if not skipped and incomplete
            if ! $current_is_skipped && ! $current_is_complete && [[ -n "$current_block" ]]; then
                result+="$current_block"
            fi

            # Check if this task matches a template default
            local task_name="${line#*] }"
            if [[ "$skip_names" == *$'\n'"$task_name"$'\n'* ]]; then
                current_is_skipped=true
            else
                current_is_skipped=false
            fi

            if [[ "$line" =~ $re_top_x ]]; then
                current_is_complete=true
            else
                current_is_complete=false
            fi
            current_block="$line"$'\n'

        # Subtask
        elif [[ "$line" == *"- ["*"]"* ]] && [[ "$line" =~ ^[[:space:]] ]]; then
            if ! $current_is_complete && ! $current_is_skipped; then
                if [[ ! "$line" =~ $re_sub_x ]]; then
                    current_block+="$line"$'\n'
                fi
            fi

        # Blank line between task groups
        elif [[ -z "$line" ]]; then
            if ! $current_is_skipped && ! $current_is_complete; then
                current_block+=$'\n'
            fi
        fi
    done < "$source_file"

    # Flush last block
    if ! $current_is_skipped && ! $current_is_complete && [[ -n "$current_block" ]]; then
        result+="$current_block"
    fi

    printf '%s' "$result"
}

function jtm() {
    local -a _jtm_flags=(-h --help -d --date -n --next -p --prev -cf --carry-forward -cfl --carry-forward-latest)
    local arg_date=""
    local next=false
    local prev=false
    local carry_forward=false
    local carry_forward_latest=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                _jt_help jtm day
                return 0
                ;;
            -d|--date)
                if [[ -z "${2:-}" || "$2" == -* ]]; then
                    _jt_err "flag ${_jt_bold}-d/--date${_jt_reset} requires a ${_jt_cyan}YYYY-MM-DD${_jt_reset} value"
                    return 1
                fi
                if ! date -d "$2" +%Y-%m-%d &>/dev/null; then
                    _jt_err "invalid date ${_jt_bold}$2${_jt_reset} — expected ${_jt_cyan}YYYY-MM-DD${_jt_reset}"
                    return 1
                fi
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
            -cf|--carry-forward)
                carry_forward=true
                shift
                ;;
            -cfl|--carry-forward-latest)
                carry_forward_latest=true
                shift
                ;;
            *)
                _jt_err "unknown flag ${_jt_bold}$1${_jt_reset}"
                _jt_suggest_flag "$1" "${_jtm_flags[@]}"
                printf '\n%s\n' "    run ${_jt_cyan}jtm --help${_jt_reset} for usage" >&2
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
    local template="$NOTES/journal/$ADMIN/daily/template.md"
    local carry_tasks=""

    if [[ ! -f "$template" ]]; then
        _jt_err "template not found at ${_jt_bold}${template}${_jt_reset}"
        return 1
    fi

    if ($carry_forward || $carry_forward_latest) && [[ -f "$file" ]]; then
        _jt_info "${_jt_bold}${ref_date}${_jt_reset} already exists — skipping carry-forward"
        $EDITOR "$file"
        return 0
    fi

    if $carry_forward; then
        local prev_date
        prev_date=$(date -d "$ref_date -1 day" +%Y-%m-%d)
        local prev_file="$NOTES/journal/$ADMIN/daily/$prev_date.md"
        if [[ ! -f "$prev_file" ]]; then
            _jt_warn "no journal entry for ${_jt_bold}${prev_date}${_jt_reset} — nothing to carry forward"
        else
            carry_tasks=$(_jtm_carry_forward "$prev_file" "$template")
            if [[ -z "$carry_tasks" ]]; then
                _jt_info "no incomplete tasks in ${_jt_bold}${prev_date}${_jt_reset}"
            else
                _jt_ok "carried forward tasks from ${_jt_bold}${prev_date}${_jt_reset}"
            fi
        fi
    elif $carry_forward_latest; then
        local latest_file
        latest_file=$(ls "$NOTES/journal/$ADMIN/daily/"????-??-??.md 2>/dev/null \
            | grep -v "$ref_date" \
            | sort -r \
            | while read -r f; do
                local fname
                fname=$(basename "$f" .md)
                if [[ "$fname" < "$ref_date" ]]; then
                    echo "$f"
                    break
                fi
            done)
        if [[ -n "$latest_file" ]]; then
            carry_tasks=$(_jtm_carry_forward "$latest_file" "$template")
            local src_date
            src_date=$(basename "$latest_file" .md)
            if [[ -z "$carry_tasks" ]]; then
                _jt_info "no incomplete tasks in ${_jt_bold}${src_date}${_jt_reset}"
            else
                _jt_ok "carried forward tasks from ${_jt_bold}${src_date}${_jt_reset}"
            fi
        else
            _jt_warn "no previous journal entries found"
        fi
    fi

    if [[ ! -f $file ]]; then
        if [[ -n "$carry_tasks" ]]; then
            local tmpfile
            tmpfile=$(mktemp)
            local inserted=false
            while IFS= read -r line; do
                if [[ "$line" =~ ^##[[:space:]]+Backlog ]] && ! $inserted; then
                    printf '%s\n' "$carry_tasks" >> "$tmpfile"
                    inserted=true
                fi
                printf '%s\n' "$line" >> "$tmpfile"
            done < "$template"
            if ! $inserted; then
                printf '\n%s\n' "$carry_tasks" >> "$tmpfile"
            fi
            $EDITOR -c "0r $tmpfile" -c "autocmd BufDelete * silent! call delete('$tmpfile')" "$file"
        else
            $EDITOR -c "0r $NOTES/journal/$ADMIN/daily/template.md" "$file"
        fi
    else
        $EDITOR "$file"
    fi
}

function jtw() {
    local -a _jtw_flags=(-h --help -d --date -n --next -p --prev -cf --carry-forward -cfl --carry-forward-latest)
    local arg_date=""
    local next=false
    local prev=false
    local carry_forward=false
    local carry_forward_latest=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                _jt_help jtw week
                return 0
                ;;
            -d|--date)
                if [[ -z "${2:-}" || "$2" == -* ]]; then
                    _jt_err "flag ${_jt_bold}-d/--date${_jt_reset} requires a ${_jt_cyan}YYYY-MM-DD${_jt_reset} value"
                    return 1
                fi
                if ! date -d "$2" +%Y-%m-%d &>/dev/null; then
                    _jt_err "invalid date ${_jt_bold}$2${_jt_reset} — expected ${_jt_cyan}YYYY-MM-DD${_jt_reset}"
                    return 1
                fi
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
            -cf|--carry-forward)
                carry_forward=true
                shift
                ;;
            -cfl|--carry-forward-latest)
                carry_forward_latest=true
                shift
                ;;
            *)
                _jt_err "unknown flag ${_jt_bold}$1${_jt_reset}"
                _jt_suggest_flag "$1" "${_jtw_flags[@]}"
                printf '\n%s\n' "    run ${_jt_cyan}jtw --help${_jt_reset} for usage" >&2
                return 1
                ;;
        esac
    done

    local ref_date=${arg_date:-$(date +%Y-%m-%d)}
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
    local template="$NOTES/journal/$ADMIN/weekly/template.md"
    local carry_tasks=""

    if [[ ! -f "$template" ]]; then
        _jt_err "template not found at ${_jt_bold}${template}${_jt_reset}"
        return 1
    fi

    if ($carry_forward || $carry_forward_latest) && [[ -f "$file" ]]; then
        _jt_info "${_jt_bold}${sunday}${_jt_reset} already exists — skipping carry-forward"
        $EDITOR "$file"
        return 0
    fi

    if $carry_forward; then
        local prev_sunday
        prev_sunday=$(date -d "$sunday -7 days" +%Y-%m-%d)
        local prev_file="$NOTES/journal/$ADMIN/weekly/$prev_sunday.md"
        if [[ ! -f "$prev_file" ]]; then
            _jt_warn "no weekly entry for ${_jt_bold}${prev_sunday}${_jt_reset} — nothing to carry forward"
        else
            carry_tasks=$(_jtm_carry_forward "$prev_file" "$template")
            if [[ -z "$carry_tasks" ]]; then
                _jt_info "no incomplete tasks in ${_jt_bold}${prev_sunday}${_jt_reset}"
            else
                _jt_ok "carried forward tasks from ${_jt_bold}${prev_sunday}${_jt_reset}"
            fi
        fi
    elif $carry_forward_latest; then
        local latest_file
        latest_file=$(ls "$NOTES/journal/$ADMIN/weekly/"????-??-??.md 2>/dev/null \
            | grep -v "$sunday" \
            | sort -r \
            | while read -r f; do
                local fname
                fname=$(basename "$f" .md)
                if [[ "$fname" < "$sunday" ]]; then
                    echo "$f"
                    break
                fi
            done)
        if [[ -n "$latest_file" ]]; then
            carry_tasks=$(_jtm_carry_forward "$latest_file" "$template")
            local src_date
            src_date=$(basename "$latest_file" .md)
            if [[ -z "$carry_tasks" ]]; then
                _jt_info "no incomplete tasks in ${_jt_bold}${src_date}${_jt_reset}"
            else
                _jt_ok "carried forward tasks from ${_jt_bold}${src_date}${_jt_reset}"
            fi
        else
            _jt_warn "no previous weekly entries found"
        fi
    fi

    if [[ ! -f $file ]]; then
        if [[ -n "$carry_tasks" ]]; then
            local tmpfile
            tmpfile=$(mktemp)
            cat "$template" > "$tmpfile"
            printf '\n%s\n' "$carry_tasks" >> "$tmpfile"
            $EDITOR -c "0r $tmpfile" -c "autocmd BufDelete * silent! call delete('$tmpfile')" "$file"
        else
            $EDITOR -c "0r $NOTES/journal/$ADMIN/weekly/template.md" "$file"
        fi
    else
        $EDITOR "$file"
    fi
}

alias jtg='rg --color=always --line-number --no-heading --smart-case "${*:-}" "$NOTES/journal" \
  | fzf --ansi --delimiter : \
        --preview "bat --color=always {1} --highlight-line {2}" \
        --bind "enter:become($EDITOR {1} +{2})"'
