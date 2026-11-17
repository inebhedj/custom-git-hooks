# shellcheck shell=sh
# Tests of payload/cgh-check

CHECK=.githooks/cgh-check

# setup: installed repository with a topic branch; commits are made with
# CGH_SKIP=1 so that the client hooks do not get in the way
setup() {
    new_repo
    install_hooks
    git switch -q -c ABC-1-topic
}

commit() { # subject
    CGH_SKIP=1 git commit -q --allow-empty -m "$1"
}

test_passes_when_everything_is_fine() {
    setup
    commit 'ABC-1: first'
    commit 'NOJIRA: second'
    for sh_bin in $(shells); do
        run "$sh_bin" "$CHECK" --base master
        assert_rc 0 "$sh_bin"
        assert_contains "$OUT" 'Branch name: ABC-1-topic ok'
        assert_contains "$OUT" 'Commit subjects: 2 checked, 0 wrong'
    done
}

test_fails_and_names_the_commit_without_a_ticket() {
    setup
    commit 'ABC-1: first'
    commit 'forgot the ticket'
    run sh "$CHECK" --base master
    assert_rc 1
    assert_contains "$OUT" 'forgot the ticket'
    assert_contains "$OUT" '1 wrong'
}

test_only_the_commits_after_the_base_are_checked() {
    setup
    commit 'ABC-1: good'
    run sh "$CHECK" --base master
    assert_rc 0
    assert_contains "$OUT" '1 checked'
}

test_fixup_and_merge_commits_are_skipped() {
    setup
    commit 'ABC-1: first'
    commit 'fixup! ABC-1: first'
    commit 'squash! ABC-1: first'
    git switch -q -c ABC-2-other master
    commit 'ABC-2: other'
    git switch -q ABC-1-topic
    CGH_SKIP=1 git merge -q --no-ff -m 'Merge branch other' ABC-2-other
    run sh "$CHECK" --base master
    assert_rc 0
    assert_contains "$OUT" '2 checked, 0 wrong'
}

test_fails_on_a_bad_branch_name() {
    setup
    git switch -q -c bad_name
    commit 'ABC-1: fine'
    run sh "$CHECK" --base master
    assert_rc 1
    assert_contains "$OUT" "'bad_name' does not match"
}

test_branch_can_be_given_or_come_from_github() {
    setup
    commit 'ABC-1: fine'
    git switch -q --detach
    run sh "$CHECK" --base master
    assert_rc 0
    assert_contains "$OUT" 'detached HEAD'
    run sh "$CHECK" --base master --branch wrong_name
    assert_rc 1
    GITHUB_HEAD_REF=ABC-9-from-github run sh "$CHECK" --base master
    assert_rc 0
    assert_contains "$OUT" 'ABC-9-from-github ok'
}

test_base_can_come_from_the_environment() {
    setup
    commit 'no ticket'
    CGH_BASE=master run sh "$CHECK"
    assert_rc 1
}

test_without_a_base_only_the_last_commit_is_checked() {
    setup
    commit 'old and wrong'
    commit 'ABC-1: last one is fine'
    run sh "$CHECK"
    assert_rc 0
    assert_contains "$OUT" '1 checked'
}

test_protected_branches_are_not_checked_for_their_name() {
    setup
    git switch -q master
    run sh "$CHECK"
    assert_rc 1
    assert_contains "$OUT" 'protected branch'
    assert_contains "$OUT" 'initial'
}

test_a_missing_base_is_an_error() {
    setup
    run sh "$CHECK" --base does-not-exist
    assert_rc 1
    assert_contains "$OUT" 'cannot list'
}

test_configuration_applies() {
    setup
    git config cgh.ticket-regex 'PROJ_[0-9]+'
    git config cgh.branch-regex '^ABC-[0-9]+-topic$'
    commit 'PROJ_5: configured'
    run sh "$CHECK" --base master
    assert_rc 0
}

test_usage_errors() {
    setup
    run sh "$CHECK" --bogus
    assert_rc 2
    run sh "$CHECK" --base
    assert_rc 2
}

test_cgh_check_is_available_through_the_cli() {
    setup
    commit 'ABC-1: fine'
    run "$ROOT/bin/cgh" check --base master
    assert_rc 0
}
