# shellcheck shell=sh
# custom-git-hooks shared helpers (POSIX sh). Sourced by the hook scripts:
#
#   CGH_HOME=${CGH_HOME:-$(cd "$(dirname "$0")/../.." && pwd -P)}
#   . "$CGH_HOME/lib.sh"

cgh_say() {
    printf '%s\n' "$*" >&2
}

# cgh_conf KEY DEFAULT
#
# Looks KEY up in this order (first non-empty value wins):
#   1. environment variable CGH_<KEY in capitals>   (CGH_TICKET_REGEX)
#   2. git config cgh.<key with - instead of _>     (cgh.ticket-regex)
#   3. "key = value" line in $CGH_HOME/cgh.conf
#   4. DEFAULT
cgh_conf() {
    _key=$1
    _def=$2

    _env=CGH_$(printf '%s' "$_key" | tr '[:lower:]' '[:upper:]')
    eval "_val=\${$_env:-}"
    if [ -n "$_val" ]; then
        printf '%s\n' "$_val"
        return 0
    fi

    _val=$(git config --get "cgh.$(printf '%s' "$_key" | tr '_' '-')" 2>/dev/null) || _val=
    if [ -n "$_val" ]; then
        printf '%s\n' "$_val"
        return 0
    fi

    if [ -f "$CGH_HOME/cgh.conf" ]; then
        _val=$(sed -n "s/^[[:space:]]*${_key}[[:space:]]*=[[:space:]]*//p" "$CGH_HOME/cgh.conf" |
            sed -n '1s/[[:space:]]*$//p')
        if [ -n "$_val" ]; then
            printf '%s\n' "$_val"
            return 0
        fi
    fi

    printf '%s\n' "$_def"
}

# ERE matching a ticket key, e.g. ABC-123
cgh_ticket_re() {
    cgh_conf ticket_regex '[A-Z][A-Z0-9]+-[0-9]+'
}

# the token used when there is no ticket
cgh_no_ticket() {
    cgh_conf no_ticket 'NOJIRA'
}

# ERE every (new) branch name must match
cgh_branch_regex() {
    _re=$(cgh_conf branch_regex '')
    if [ -n "$_re" ]; then
        printf '%s\n' "$_re"
        return 0
    fi
    printf '^(%s|%s)-[a-zA-Z0-9-]+$\n' "$(cgh_ticket_re)" "$(cgh_no_ticket)"
}

# cgh_leading_ticket STRING: prints the ticket key (or the no-ticket token)
# STRING starts with, or nothing.
cgh_leading_ticket() {
    _re=$(cgh_ticket_re)
    _no=$(cgh_no_ticket)
    printf '%s\n' "$1" | grep -oE "^($_re|$_no)" | head -n 1
}

# current branch name; empty on a detached HEAD
cgh_branch() {
    git symbolic-ref -q --short HEAD 2>/dev/null
}

# true while a merge, rebase, cherry-pick or revert is in progress
cgh_in_progress() {
    _gd=$(git rev-parse --git-dir 2>/dev/null) || return 1
    for _f in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply; do
        [ -e "$_gd/$_f" ] && return 0
    done
    return 1
}

# cgh_is_protected BRANCH: is BRANCH matched by the protected_branches globs?
# (set protected_branches to "none" to protect nothing)
cgh_is_protected() {
    _list=$(cgh_conf protected_branches 'master main')
    _hit=1
    set -f
    for _p in $_list; do
        # shellcheck disable=SC2254 # the pattern is meant to be a glob
        case $1 in
            $_p)
                _hit=0
                break
                ;;
        esac
    done
    set +f
    return "$_hit"
}

# Where interactive answers are read from / prompts are written to.
# Overridable so that the prompt can be tested without a terminal.
cgh_tty_in() {
    printf '%s\n' "${CGH_TTY_IN:-/dev/tty}"
}

cgh_tty_out() {
    printf '%s\n' "${CGH_TTY_OUT:-/dev/tty}"
}

# true if there is somebody to ask
cgh_tty_ok() {
    _in=$(cgh_tty_in)
    ( : <"$_in" ) 2>/dev/null
}
