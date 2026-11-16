# shellcheck shell=sh
# Tests of install.sh

test_installs_the_files_and_sets_hookspath() {
    new_repo
    install_hooks
    assert_eq '.githooks' "$(git config --local core.hooksPath)"
    assert_exec .githooks/_dispatch
    assert_file .githooks/lib.sh
    assert_file .githooks/cgh.conf
    assert_file .githooks/.cgh-manifest
    assert_exec .githooks/hooks.d/commit-msg/00-jira-prefix
    assert_exec .githooks/hooks.d/pre-commit/00-branch-name
    assert_exec .githooks/hooks.d/pre-commit/10-protected-branch
    assert_exec .githooks/commit-msg
    assert_exec .githooks/pre-commit
    assert_no_file .githooks/pre-push
}

test_the_installed_hooks_work_end_to_end() {
    new_repo
    install_hooks
    git switch -q -c ABC-5-feature
    git commit -q --allow-empty -m 'Add feature'
    assert_eq 'ABC-5: Add feature' "$(last_message)"
}

test_reinstalling_keeps_the_configuration_and_own_hooks() {
    new_repo
    install_hooks
    printf 'no_ticket = MINE\n' >.githooks/cgh.conf
    mkdir -p .githooks/hooks.d/post-commit
    printf '#!/bin/sh\ntrue\n' >.githooks/hooks.d/post-commit/00-own
    chmod +x .githooks/hooks.d/post-commit/00-own
    install_hooks
    assert_eq 'no_ticket = MINE' "$(cat .githooks/cgh.conf)"
    assert_exec .githooks/hooks.d/post-commit/00-own
    assert_exec .githooks/post-commit
}

test_reinstalling_removes_outdated_managed_files_only() {
    new_repo
    install_hooks
    printf '#!/bin/sh\n' >.githooks/hooks.d/pre-commit/05-outdated
    printf '05-outdated is removed' >.githooks/hooks.d/pre-commit/99-mine
    echo 'hooks.d/pre-commit/05-outdated' >>.githooks/.cgh-manifest
    install_hooks
    assert_no_file .githooks/hooks.d/pre-commit/05-outdated
    assert_file .githooks/hooks.d/pre-commit/99-mine
}

test_dry_run_changes_nothing() {
    new_repo
    run sh "$ROOT/install.sh" --dry-run
    assert_rc 0
    assert_contains "$OUT" 'dry-run'
    assert_no_file .githooks
    assert_eq '' "$(git config --local --get core.hooksPath || true)"
}

test_uninstall_removes_what_was_installed_and_keeps_user_files() {
    new_repo
    install_hooks
    mkdir -p .githooks/hooks.d/post-commit
    printf '#!/bin/sh\n' >.githooks/hooks.d/post-commit/00-own
    sh "$ROOT/install.sh" --uninstall >/dev/null
    assert_no_file .githooks/_dispatch
    assert_no_file .githooks/commit-msg
    assert_no_file .githooks/hooks.d/commit-msg
    assert_no_file .githooks/.cgh-manifest
    assert_file .githooks/cgh.conf
    assert_file .githooks/hooks.d/post-commit/00-own
    assert_eq '' "$(git config --local --get core.hooksPath || true)"
}

test_uninstall_of_the_default_install_leaves_nothing_behind_but_the_config() {
    new_repo
    install_hooks
    sh "$ROOT/install.sh" --uninstall >/dev/null
    assert_eq 'cgh.conf' "$(ls -A .githooks)"
}

test_refuses_to_replace_a_different_hookspath() {
    new_repo
    git config core.hooksPath .husky
    run sh "$ROOT/install.sh"
    [ "$RC" -ne 0 ] || fail "should have been refused"
    assert_contains "$OUT" '.husky'
    assert_eq '.husky' "$(git config --local core.hooksPath)"
    run sh "$ROOT/install.sh" --force
    assert_rc 0
    assert_eq '.githooks' "$(git config --local core.hooksPath)"
}

test_does_not_overwrite_a_foreign_hook_file_without_force() {
    new_repo
    mkdir -p .githooks
    printf '#!/bin/sh\necho mine\n' >.githooks/commit-msg
    chmod +x .githooks/commit-msg
    run sh "$ROOT/install.sh"
    assert_rc 0
    assert_contains "$OUT" 'not a cgh stub'
    assert_contains "$(cat .githooks/commit-msg)" 'echo mine'
}

test_installs_into_another_repository_given_as_argument() {
    new_repo
    other=$(mktemp -d "$T_TMP/other.XXXXXX")
    git -C "$other" init -q -b master
    run sh "$ROOT/install.sh" "$other"
    assert_rc 0
    assert_file "$other/.githooks/_dispatch"
    assert_eq '.githooks' "$(git -C "$other" config --local core.hooksPath)"
    assert_no_file .githooks
}

test_fails_outside_a_git_repository() {
    cd "$T_TMP" || exit 1
    mkdir -p not-a-repo && cd not-a-repo || exit 1
    run sh "$ROOT/install.sh"
    [ "$RC" -ne 0 ] || fail "should have failed"
    assert_contains "$OUT" 'not inside a git repository'
}

test_custom_directory() {
    new_repo
    install_hooks --dir tools/hooks
    assert_exec tools/hooks/_dispatch
    assert_eq 'tools/hooks' "$(git config --local core.hooksPath)"
    git switch -q -c ABC-1-x
    git commit -q --allow-empty -m 'works'
    assert_eq 'ABC-1: works' "$(last_message)"
}

test_warns_about_an_old_installation() {
    new_repo
    printf '#!/bin/sh\n# CUSTOM-GIT-HOOK-SKELETON\n' >.git/hooks/commit-msg
    run sh "$ROOT/install.sh"
    assert_rc 0
    assert_contains "$OUT" 'older custom-git-hooks version'
}
