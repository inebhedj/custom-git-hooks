# shellcheck shell=sh
# Tests of payload/hooks.d/pre-commit/*

BRANCH_HOOK=.githooks/hooks.d/pre-commit/00-branch-name
PROTECT_HOOK=.githooks/hooks.d/pre-commit/10-protected-branch

setup() {
    new_repo
    install_hooks
}

# ---- 00-branch-name ---------------------------------------------------------

test_accepts_ticket_and_nojira_branch_names() {
    setup
    for b in ABC-123-fix-it NOJIRA-refactor-2 AB2-7-x; do
        git switch -q -c "$b"
        for sh_bin in $(shells); do
            run "$sh_bin" "$BRANCH_HOOK"
            assert_rc 0 "$sh_bin $b"
        done
    done
}

test_rejects_a_bad_name_on_a_new_branch() {
    setup
    git switch -q -c bad_name
    for sh_bin in $(shells); do
        run "$sh_bin" "$BRANCH_HOOK"
        assert_rc 1 "$sh_bin"
        assert_contains "$OUT" '[ERROR]'
        assert_contains "$OUT" 'git branch -m NOJIRA-bad-name'
    done
}

test_only_warns_about_a_bad_name_on_an_old_branch() {
    setup
    git switch -q -c bad_name
    git commit -q --allow-empty --no-verify -m 'own commit'
    run sh "$BRANCH_HOOK"
    assert_rc 0
    assert_contains "$OUT" '[NOTICE]'
}

test_does_not_check_a_detached_head() {
    setup
    git switch -q --detach
    run sh "$BRANCH_HOOK"
    assert_rc 0
}

test_branch_regex_is_configurable() {
    setup
    git config cgh.branch-regex '^(feature|fix)/[a-z-]+$'
    git switch -q -c feature/login
    run sh "$BRANCH_HOOK"
    assert_rc 0
    git switch -q -c nope
    run sh "$BRANCH_HOOK"
    assert_rc 1
}

test_a_bad_new_branch_blocks_a_real_commit() {
    setup
    git switch -q -c bad_name
    git commit -q --allow-empty -m 'x' 2>"$T_TMP/err"
    [ $? -ne 0 ] || fail "commit should have been rejected"
    assert_contains "$(cat "$T_TMP/err")" 'bad_name'
}

# ---- 10-protected-branch ----------------------------------------------------

test_rejects_without_a_terminal() {
    setup
    CGH_TTY_IN=/nonexistent
    export CGH_TTY_IN
    for sh_bin in $(shells); do
        run "$sh_bin" "$PROTECT_HOOK"
        assert_rc 1 "$sh_bin"
        assert_contains "$OUT" 'CGH_ALLOW_PROTECTED=1'
    done
}

test_override_variable_allows_the_commit() {
    setup
    CGH_TTY_IN=/nonexistent CGH_ALLOW_PROTECTED=1 run sh "$PROTECT_HOOK"
    assert_rc 0
}

test_asks_and_accepts_yes() {
    setup
    printf 'y\n' >"$T_TMP/answer"
    CGH_TTY_IN="$T_TMP/answer" CGH_TTY_OUT=/dev/null run sh "$PROTECT_HOOK"
    assert_rc 0
}

test_asks_and_rejects_no_and_empty_answers() {
    setup
    for a in n no N ''; do
        printf '%s\n' "$a" >"$T_TMP/answer"
        CGH_TTY_IN="$T_TMP/answer" CGH_TTY_OUT=/dev/null run sh "$PROTECT_HOOK"
        assert_rc 1 "answer '$a'"
    done
}

test_asks_again_after_an_invalid_answer() {
    setup
    printf 'maybe\ny\n' >"$T_TMP/answer"
    CGH_TTY_IN="$T_TMP/answer" CGH_TTY_OUT=/dev/null run sh "$PROTECT_HOOK"
    assert_rc 0
}

test_a_closed_input_means_no() {
    setup
    : >"$T_TMP/answer"
    CGH_TTY_IN="$T_TMP/answer" CGH_TTY_OUT=/dev/null run sh "$PROTECT_HOOK"
    assert_rc 1
}

test_other_branches_are_not_asked() {
    setup
    git switch -q -c ABC-1-topic
    CGH_TTY_IN=/nonexistent run sh "$PROTECT_HOOK"
    assert_rc 0
}

test_protected_branches_are_configurable_globs() {
    setup
    git config cgh.protected-branches 'release/* hotfix'
    git switch -q -c release/1.0
    CGH_TTY_IN=/nonexistent run sh "$PROTECT_HOOK"
    assert_rc 1
    git switch -q master
    CGH_TTY_IN=/nonexistent run sh "$PROTECT_HOOK"
    assert_rc 0 "master is not protected any more"
}

test_none_protects_nothing() {
    setup
    git config cgh.protected-branches none
    CGH_TTY_IN=/nonexistent run sh "$PROTECT_HOOK"
    assert_rc 0
}

test_a_real_commit_to_master_is_rejected_without_a_terminal() {
    setup
    CGH_TTY_IN=/nonexistent
    export CGH_TTY_IN
    git commit -q --allow-empty -m 'x' 2>/dev/null
    [ $? -ne 0 ] || fail "commit to master should have been rejected"
    CGH_ALLOW_PROTECTED=1 git commit -q --allow-empty -m 'x' ||
        fail "override should allow the commit"
    assert_eq 'NOJIRA: x' "$(last_message)"
}

test_a_merge_commit_on_master_is_not_asked() {
    setup
    git switch -q -c ABC-1-topic
    echo a >a && git add a && git commit -q -m 'topic work'
    git switch -q master
    echo b >b && git add b && CGH_ALLOW_PROTECTED=1 git commit -q -m 'master work'
    CGH_TTY_IN=/nonexistent
    export CGH_TTY_IN
    git merge -q --no-edit ABC-1-topic || fail "merge should not be blocked"
}
