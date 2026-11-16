#!/bin/sh
# Dependency-free test runner (POSIX sh).
#
#   sh tests/run.sh              run everything
#   sh tests/run.sh commit_msg   only tests/test_commit_msg.sh
#
# Every function called test_* in tests/test_*.sh runs in its own subshell
# against a fresh temporary git repository (see tests/lib.sh).

ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
export ROOT

T_TMP=$(mktemp -d "${TMPDIR:-/tmp}/cgh-tests.XXXXXX") || exit 1
export T_TMP
trap 'rm -rf "$T_TMP"' EXIT
trap 'exit 1' HUP INT TERM

# Never let the developer's own git configuration leak into the tests.
export HOME="$T_TMP/home"
mkdir -p "$HOME"
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
export GIT_TERMINAL_PROMPT=0
unset CGH_SKIP CGH_DEBUG CGH_ALLOW_PROTECTED CGH_HOME
unset CGH_TICKET_REGEX CGH_NO_TICKET CGH_BRANCH_REGEX CGH_PROTECTED_BRANCHES
unset CGH_TTY_IN CGH_TTY_OUT

pass=0
fail=0
failed_list=

for file in "$ROOT"/tests/test_*.sh; do
    name=${file##*/test_}
    name=${name%.sh}
    if [ $# -gt 0 ] && [ "$1" != "$name" ]; then
        continue
    fi
    echo "== $name"
    # shellcheck source=/dev/null
    . "$ROOT/tests/lib.sh"
    # shellcheck source=/dev/null
    . "$file"
    for fn in $(sed -n 's/^\(test_[A-Za-z0-9_]*\)().*/\1/p' "$file"); do
        T_CURRENT="$name.$fn"
        ( "$fn" ) >"$T_TMP/out" 2>&1
        rc=$?
        if [ $rc -eq 0 ]; then
            pass=$((pass + 1))
            echo "  ok   $fn"
        else
            fail=$((fail + 1))
            failed_list="$failed_list $T_CURRENT"
            echo "  FAIL $fn"
            sed 's/^/       | /' "$T_TMP/out"
        fi
    done
done

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
