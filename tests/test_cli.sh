# shellcheck shell=sh
# Tests of bin/cgh

# link_cgh: puts a symlink to bin/cgh into a fresh directory, like
# node_modules/.bin does. Sets $CGH.
link_cgh() {
    bindir=$(mktemp -d "$T_TMP/bin.XXXXXX")
    ln -s "$ROOT/bin/cgh" "$bindir/cgh"
    CGH="$bindir/cgh"
}

test_version_works_through_a_symlink() {
    link_cgh
    run "$CGH" version
    assert_rc 0
    assert_eq "$(cat "$ROOT/VERSION")" "$OUT"
}

test_install_and_uninstall() {
    new_repo
    link_cgh
    run "$CGH" install
    assert_rc 0
    assert_exec .githooks/_dispatch
    assert_exec .githooks/cgh-check
    assert_eq .githooks "$(git config --local core.hooksPath)"
    run "$CGH" uninstall
    assert_rc 0
    assert_no_file .githooks/_dispatch
}

test_prepare_installs_quietly() {
    new_repo
    link_cgh
    run "$CGH" prepare
    assert_rc 0
    assert_eq 'custom-git-hooks: hooks installed' "$OUT"
    assert_eq .githooks "$(git config --local core.hooksPath)"
}

test_prepare_does_nothing_on_ci() {
    new_repo
    link_cgh
    CI=true run "$CGH" prepare
    assert_rc 0
    assert_eq '' "$OUT"
    assert_eq '' "$(git config --local --get core.hooksPath || true)"
}

test_prepare_can_be_switched_off() {
    new_repo
    link_cgh
    CGH_SKIP_INSTALL=1 run "$CGH" prepare
    assert_rc 0
    assert_eq '' "$(git config --local --get core.hooksPath || true)"
}

test_prepare_outside_of_a_repository_is_silent_and_succeeds() {
    link_cgh
    cd "$(mktemp -d "$T_TMP/plain.XXXXXX")" || exit 1
    run "$CGH" prepare
    assert_rc 0
    assert_eq '' "$OUT"
}

test_prepare_never_fails_even_when_the_install_does() {
    new_repo
    link_cgh
    git config core.hooksPath .husky
    run "$CGH" prepare
    assert_rc 0
    assert_contains "$OUT" 'installation skipped'
    assert_eq .husky "$(git config --local core.hooksPath)"
}

test_unknown_command_is_a_usage_error() {
    link_cgh
    run "$CGH" frobnicate
    assert_rc 2
    assert_contains "$OUT" 'cgh install'
}

test_help_lists_the_commands() {
    link_cgh
    run "$CGH" help
    assert_rc 0
    assert_contains "$OUT" 'cgh prepare'
    assert_contains "$OUT" 'cgh check'
}
