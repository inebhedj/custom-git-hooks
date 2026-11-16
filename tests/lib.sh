# shellcheck shell=sh
# Helpers for the tests. Sourced by tests/run.sh.

# new_repo: creates a fresh repository with one commit on master and cd's into
# it. Sets $REPO. (Every test runs in its own subshell, so the directory has
# to be unique by itself, not by a counter.)
new_repo() {
    REPO=$(mktemp -d "$T_TMP/repo.XXXXXX") || exit 1
    cd "$REPO" || exit 1
    git init -q -b master .
    git config user.name 'Test User'
    git config user.email 'test@example.com'
    git config commit.gpgsign false
    git commit -q --allow-empty -m 'initial'
}

# install_hooks [installer options]: installs into the current repository
install_hooks() {
    sh "$ROOT/install.sh" "$@" >"$T_TMP/install.log" 2>&1 || {
        cat "$T_TMP/install.log"
        fail "install.sh failed"
    }
}

# run CMD...: runs CMD, stores combined output in $OUT and status in $RC
run() {
    OUT=$("$@" 2>&1)
    RC=$?
}

# shells to try the hook scripts with directly (dash catches bashisms)
shells() {
    for _s in sh dash; do
        command -v "$_s" >/dev/null 2>&1 && printf '%s\n' "$_s"
    done
}

fail() {
    echo "assertion failed: $*" >&2
    exit 1
}

assert_eq() { # expected actual [message]
    [ "$1" = "$2" ] || fail "${3:-values differ}
      expected: $1
      actual:   $2"
}

assert_rc() { # expected-status [message]
    [ "$RC" = "$1" ] || fail "${2:-unexpected exit status}: expected $1, got $RC
      output: $OUT"
}

assert_contains() { # haystack needle [message]
    case $1 in
        *"$2"*) ;;
        *) fail "${3:-missing text}: '$2' not found in:
      $1" ;;
    esac
}

assert_not_contains() { # haystack needle [message]
    case $1 in
        *"$2"*) fail "${3:-unexpected text}: '$2' found in:
      $1" ;;
    esac
}

assert_file() {
    [ -f "$1" ] || fail "missing file: $1"
}

assert_no_file() {
    [ ! -e "$1" ] || fail "file should not exist: $1"
}

assert_exec() {
    [ -x "$1" ] || fail "not executable: $1"
}

# last_message: the full message of the last commit (use inside $(...), which
# strips the trailing newlines)
last_message() {
    git log -1 --format=%B
}
