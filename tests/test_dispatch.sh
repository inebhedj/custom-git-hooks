# shellcheck shell=sh
# Tests of payload/_dispatch and the hook stubs

# add_script HOOK NAME BODY: adds an executable script to hooks.d/HOOK
add_script() {
    mkdir -p ".githooks/hooks.d/$1"
    printf '#!/bin/sh\n%s\n' "$3" >".githooks/hooks.d/$1/$2"
    chmod +x ".githooks/hooks.d/$1/$2"
}

setup() {
    new_repo
    install_hooks
    git switch -q -c NOJIRA-dispatch
}

test_runs_the_scripts_in_lexical_order() {
    setup
    add_script post-commit 20-b 'echo b >>"$CGH_LOG"'
    add_script post-commit 10-a 'echo a >>"$CGH_LOG"'
    add_script post-commit 30-c 'echo c >>"$CGH_LOG"'
    install_hooks
    CGH_LOG="$T_TMP/log-order"
    export CGH_LOG
    git commit -q --allow-empty -m x
    assert_eq 'a
b
c' "$(cat "$CGH_LOG")"
}

test_stops_at_the_first_failure_and_passes_its_status_on() {
    setup
    add_script pre-push 00-ok 'echo ok >>"$CGH_LOG"'
    add_script pre-push 10-fail 'echo fail >>"$CGH_LOG"; exit 3'
    add_script pre-push 20-never 'echo never >>"$CGH_LOG"'
    install_hooks
    CGH_LOG="$T_TMP/log-fail"
    export CGH_LOG
    run .githooks/pre-push origin url
    assert_rc 3
    assert_eq 'ok
fail' "$(cat "$CGH_LOG")"
}

test_a_failing_hook_script_blocks_the_git_operation() {
    setup
    add_script pre-commit 05-no 'echo "nope" >&2; exit 1'
    run git commit -q --allow-empty -m x
    [ "$RC" -ne 0 ] || fail "commit should have been blocked"
    assert_contains "$OUT" nope
}

test_passes_arguments_and_stdin_to_every_script() {
    setup
    add_script pre-push 00-a 'echo "$@" >"$CGH_OUT.a.args"; cat >"$CGH_OUT.a.in"'
    add_script pre-push 10-b 'echo "$@" >"$CGH_OUT.b.args"; cat >"$CGH_OUT.b.in"'
    install_hooks
    CGH_OUT="$T_TMP/out-args"
    export CGH_OUT
    printf 'refs/heads/x abc refs/heads/x def\n' | .githooks/pre-push origin git@example.com:x.git
    for s in a b; do
        assert_eq 'origin git@example.com:x.git' "$(cat "$CGH_OUT.$s.args")" "args of $s"
        assert_eq 'refs/heads/x abc refs/heads/x def' "$(cat "$CGH_OUT.$s.in")" "stdin of $s"
    done
}

test_ignores_samples_backups_disabled_and_non_executable_files() {
    setup
    add_script post-commit 00-real 'echo real >>"$CGH_LOG"'
    add_script post-commit 10-x.sample 'echo sample >>"$CGH_LOG"'
    add_script post-commit 20-x.backup 'echo backup >>"$CGH_LOG"'
    add_script post-commit 30-x.disabled 'echo disabled >>"$CGH_LOG"'
    add_script post-commit 40-not-executable 'echo noexec >>"$CGH_LOG"'
    chmod -x .githooks/hooks.d/post-commit/40-not-executable
    install_hooks
    CGH_LOG="$T_TMP/log-ignored"
    export CGH_LOG
    git commit -q --allow-empty -m x
    assert_eq 'real' "$(cat "$CGH_LOG")"
}

test_cgh_skip_skips_everything() {
    setup
    add_script post-commit 00-a 'echo a >>"$CGH_LOG"'
    install_hooks
    CGH_LOG="$T_TMP/log-skip"
    export CGH_LOG
    CGH_SKIP=1 git commit -q --allow-empty -m 'no prefix'
    assert_no_file "$CGH_LOG"
    assert_eq 'no prefix' "$(last_message)"
}

test_a_legacy_hook_in_git_hooks_still_runs() {
    new_repo
    printf '#!/bin/sh\necho legacy >>"$CGH_LOG"\n' >.git/hooks/post-commit
    chmod +x .git/hooks/post-commit
    install_hooks
    git switch -q -c NOJIRA-legacy
    CGH_LOG="$T_TMP/log-legacy"
    export CGH_LOG
    git commit -q --allow-empty -m x
    assert_eq 'legacy' "$(cat "$CGH_LOG")"
}

test_a_hook_of_the_old_skeleton_is_not_run_again() {
    new_repo
    printf '#!/bin/sh\n# CUSTOM-GIT-HOOK-SKELETON\necho skeleton >>"$CGH_LOG"\n' >.git/hooks/post-commit
    chmod +x .git/hooks/post-commit
    install_hooks
    git switch -q -c NOJIRA-legacy
    CGH_LOG="$T_TMP/log-skeleton"
    export CGH_LOG
    git commit -q --allow-empty -m x
    assert_no_file "$CGH_LOG"
}

test_does_not_wait_for_an_interactive_stdin() {
    setup
    add_script post-commit 00-a 'echo ran >>"$CGH_LOG"'
    install_hooks
    CGH_LOG="$T_TMP/log-tty"
    export CGH_LOG
    # a stdin that is a terminal would block `cat`; without a tty available
    # in CI we at least check that a closed stdin works
    .githooks/post-commit <&-
    assert_eq 'ran' "$(cat "$CGH_LOG")"
}
