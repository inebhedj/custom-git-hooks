# shellcheck shell=sh
# Tests of payload/hooks.d/commit-msg/00-ticket-prefix

HOOK=.githooks/hooks.d/commit-msg/00-ticket-prefix

setup_branch() { # branch-name
    new_repo
    install_hooks
    git switch -q -c "$1"
}

test_prefixes_the_subject_with_the_ticket_of_the_branch() {
    setup_branch ABC-123-fix-it
    git commit -q --allow-empty -m 'Fix it'
    assert_eq 'ABC-123: Fix it' "$(last_message)"
}

# A new branch without a ticket is refused by the pre-commit hook, so the
# NOJIRA fallback shows on branches that are not checked: protected ones.
test_uses_nojira_when_the_branch_has_no_ticket() {
    new_repo
    install_hooks
    CGH_ALLOW_PROTECTED=1 git commit -q --allow-empty -m 'Do things'
    assert_eq 'NOJIRA: Do things' "$(last_message)"
}

test_keeps_multiline_messages_and_comments_intact() {
    setup_branch ABC-1-topic
    printf 'subject line\n\nbody line 1\n# a comment\nbody line 2\n' >msg
    for sh_bin in $(shells); do
        cp msg msg.work
        run "$sh_bin" "$HOOK" msg.work
        assert_rc 0 "$sh_bin"
        assert_eq 'ABC-1: subject line

body line 1
# a comment
body line 2' "$(cat msg.work)" "$sh_bin"
    done
}

test_skips_leading_comment_and_blank_lines_of_an_editor_template() {
    setup_branch ABC-1-topic
    printf '\n# Please enter the commit message\nreal subject\n' >msg
    run sh "$HOOK" msg
    assert_rc 0
    assert_eq '
# Please enter the commit message
ABC-1: real subject' "$(cat msg)"
}

test_does_nothing_when_the_subject_already_has_the_ticket() {
    setup_branch ABC-123-fix-it
    git commit -q --allow-empty -m 'ABC-123: already there'
    assert_eq 'ABC-123: already there' "$(last_message)"
}

test_warns_about_a_different_ticket_but_leaves_the_message_alone() {
    setup_branch ABC-123-fix-it
    printf 'XYZ-9: other ticket\n' >msg
    run sh "$HOOK" msg
    assert_rc 0
    assert_contains "$OUT" 'NOTICE'
    assert_contains "$OUT" 'XYZ-9'
    assert_eq 'XYZ-9: other ticket' "$(cat msg)"
}

test_does_not_double_prefix_nojira() {
    setup_branch NOJIRA-topic
    git commit -q --allow-empty -m 'NOJIRA: already'
    assert_eq 'NOJIRA: already' "$(last_message)"
}

test_leaves_fixup_and_merge_messages_alone() {
    setup_branch ABC-1-topic
    for m in 'fixup! something' 'squash! something' 'Merge branch x'; do
        printf '%s\n' "$m" >msg
        run sh "$HOOK" msg
        assert_rc 0
        assert_eq "$m" "$(cat msg)"
    done
}

test_leaves_the_message_alone_on_a_detached_head() {
    setup_branch ABC-1-topic
    git switch -q --detach
    printf 'detached work\n' >msg
    run sh "$HOOK" msg
    assert_rc 0
    assert_eq 'detached work' "$(cat msg)"
}

test_leaves_an_empty_message_alone() {
    setup_branch ABC-1-topic
    printf '# only a comment\n\n' >msg
    run sh "$HOOK" msg
    assert_rc 0
    assert_eq '# only a comment
' "$(cat msg)
"
}

test_ticket_format_is_configurable() {
    setup_branch PROJ_42-topic
    git config cgh.ticket-regex '[A-Z]+_[0-9]+'
    git commit -q --allow-empty -m 'Configured'
    assert_eq 'PROJ_42: Configured' "$(last_message)"
}

test_cgh_conf_file_is_used_and_git_config_wins_over_it() {
    new_repo
    install_hooks
    export CGH_ALLOW_PROTECTED=1
    printf 'no_ticket = NOTICKET\n' >.githooks/cgh.conf
    git commit -q --allow-empty -m 'From file'
    assert_eq 'NOTICKET: From file' "$(last_message)"
    git config cgh.no-ticket FROMGIT
    git commit -q --allow-empty -m 'From git config'
    assert_eq 'FROMGIT: From git config' "$(last_message)"
    CGH_NO_TICKET=FROMENV git commit -q --allow-empty -m 'From env'
    assert_eq 'FROMENV: From env' "$(last_message)"
}
