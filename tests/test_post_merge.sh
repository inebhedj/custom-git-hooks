# shellcheck shell=sh
# Tests of payload/hooks.d/post-merge/00-version-bump
#
# npm is replaced by a fake one (tests need only git and a POSIX shell): it
# logs its arguments, writes version 9.9.9 and makes the commit and the tag
# like `npm version` does.

HOOK=.githooks/hooks.d/post-merge/00-version-bump

setup() {
    new_repo
    printf '{"name":"x","version":"1.2.0"}\n' >package.json
    git add package.json
    git commit -q -m 'add package.json'
    install_hooks

    FAKEBIN=$(mktemp -d "$T_TMP/bin.XXXXXX")
    NPM_LOG=$FAKEBIN/npm.log
    cat >"$FAKEBIN/npm" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"$NPM_LOG"
msg=
while [ $# -gt 0 ]; do
    case $1 in -m) msg=$2; shift ;; esac
    shift
done
msg=$(printf '%s' "$msg" | sed 's/%s/9.9.9/')
printf '{"name":"x","version":"9.9.9","build":"%s"}\n' "$$" >package.json
git add package.json
git commit -q --no-verify -m "$msg"
git tag v9.9.9
echo v9.9.9
EOF
    chmod +x "$FAKEBIN/npm"
    PATH=$FAKEBIN:$PATH
    export PATH NPM_LOG
}

# add_remote: a bare "origin" that has master
add_remote() {
    REMOTE=$(mktemp -d "$T_TMP/remote.XXXXXX")
    git init -q --bare -b master "$REMOTE"
    git remote add origin "$REMOTE"
    git push -q origin master
}

# topic NAME: a branch with one commit of its own; back on master afterwards
topic() {
    git switch -q -c "$1"
    CGH_SKIP=1 git commit -q --allow-empty -m "work on $1"
    git switch -q master
}

npm_calls() {
    cat "$NPM_LOG" 2>/dev/null
}

test_a_fast_forward_merge_bumps_the_version() {
    setup
    topic ABC-5-valami-version-minor
    git switch -q ABC-5-valami-version-minor
    git switch -q master
    run git merge -q -
    assert_rc 0
    assert_contains "$(npm_calls)" 'version minor --no-commit-hooks'
    assert_eq 'NOJIRA: Releasing version 9.9.9' "$(last_message)"
    git describe --tags --exact-match HEAD >/dev/null || fail 'no tag on HEAD'
}

test_a_merge_commit_bumps_the_version() {
    setup
    topic ABC-5-valami-version-major
    git commit -q --allow-empty -m 'diverge' --no-verify
    run git merge -q --no-ff -m 'Merge it' ABC-5-valami-version-major
    assert_rc 0
    assert_contains "$(npm_calls)" 'version major'
}

test_the_level_comes_from_the_end_of_the_name() {
    setup
    topic ABC-1-a-version-fix
    run git merge -q --no-ff -m Merge ABC-1-a-version-fix
    assert_contains "$(npm_calls)" 'version patch'
    git tag -d v9.9.9 >/dev/null
    : >"$NPM_LOG"
    topic ABC-2-b-VERSION-MINOR
    run git merge -q --no-ff -m Merge ABC-2-b-VERSION-MINOR
    assert_contains "$(npm_calls)" 'version minor'
}

test_nothing_happens_without_a_rule_in_the_name() {
    setup
    topic ABC-5-valami
    topic ABC-6-version-minor-more
    run git merge -q --no-ff -m Merge ABC-5-valami
    assert_rc 0
    run git merge -q --no-ff -m Merge ABC-6-version-minor-more
    assert_rc 0
    assert_no_file "$NPM_LOG"
}

test_other_local_branches_are_not_mistaken_for_the_merged_one() {
    # v2 looked at the list of all local branches
    setup
    topic ABC-5-old-version-major
    topic ABC-6-new
    run git merge -q --no-ff -m Merge ABC-6-new
    assert_rc 0
    assert_no_file "$NPM_LOG"
}

test_only_the_configured_branches_are_bumped() {
    setup
    git switch -q -c ABC-9-feature
    topic ABC-5-x-version-minor
    git switch -q ABC-9-feature
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0
    assert_no_file "$NPM_LOG"
}

test_version_branches_is_configurable() {
    setup
    git config cgh.version-branches 'release/*'
    git switch -q -c release/1
    topic ABC-5-x-version-minor
    git switch -q release/1
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0
    assert_contains "$(npm_calls)" 'version minor'
}

test_git_pull_does_not_bump() {
    setup
    add_remote
    topic ABC-5-x-version-minor
    # master gets the topic and is pushed without the hook
    CGH_SKIP=1 git merge -q ABC-5-x-version-minor
    git push -q origin master
    git branch -D ABC-5-x-version-minor >/dev/null
    # a second clone has a branch of that name at the new master, then pulls
    clone=$(mktemp -d "$T_TMP/clone.XXXXXX")
    git clone -q "$REMOTE" "$clone" || fail 'clone failed'
    cd "$clone" || exit 1
    git reset -q --hard HEAD~1 || fail 'reset failed'
    sh "$ROOT/install.sh" >/dev/null 2>&1 || fail 'install failed'
    git branch ABC-5-x-version-minor origin/master || fail 'branch failed'
    # the situation that fooled v2: a branch with a rule sits at the pulled commit
    assert_eq "$(git rev-parse origin/master)" "$(git rev-parse ABC-5-x-version-minor)"
    run git pull -q
    assert_rc 0
    assert_eq "$(git rev-parse origin/master)" "$(git rev-parse HEAD)" 'the pull did not fast-forward'
    assert_no_file "$NPM_LOG"
}

test_a_squash_merge_does_not_bump() {
    setup
    topic ABC-5-x-version-minor
    run git merge -q --squash ABC-5-x-version-minor
    assert_rc 0
    assert_no_file "$NPM_LOG"
}

test_without_package_json_nothing_happens() {
    setup
    git rm -q package.json
    CGH_SKIP=1 git commit -q -m 'no package.json'
    topic ABC-5-x-version-minor
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0
    assert_no_file "$NPM_LOG"
}

test_the_commit_and_the_tag_are_pushed_together() {
    setup
    add_remote
    topic ABC-5-x-version-minor
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0
    assert_eq "$(git rev-parse HEAD)" "$(git -C "$REMOTE" rev-parse refs/heads/master)" 'commit not pushed'
    assert_eq "$(git rev-parse HEAD)" "$(git -C "$REMOTE" rev-parse 'refs/tags/v9.9.9^{commit}')" 'tag not pushed'
}

test_push_can_be_switched_off() {
    setup
    add_remote
    git config cgh.version-push no
    topic ABC-5-x-version-minor
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0
    assert_contains "$OUT" 'Not pushing'
    git tag | grep -q v9.9.9 || fail 'no local tag'
    [ -z "$(git -C "$REMOTE" tag)" ] || fail 'tag was pushed'
}

test_a_rejected_push_pushes_neither_commit_nor_tag() {
    setup
    add_remote
    # somebody else moved master on the server
    other=$(mktemp -d "$T_TMP/other.XXXXXX")
    git clone -q "$REMOTE" "$other"
    git -C "$other" -c user.name=o -c user.email=o@example.com commit -q --allow-empty -m 'other work'
    git -C "$other" push -q origin master
    topic ABC-5-x-version-minor
    run git merge -q --no-ff -m Merge ABC-5-x-version-minor
    assert_rc 0 'the merge itself is not undone'
    assert_contains "$OUT" 'git push --atomic origin master v9.9.9'
    [ -z "$(git -C "$REMOTE" tag)" ] || fail 'the tag arrived without its commit'
}

test_runs_under_every_shell() {
    for sh_bin in $(shells); do
        setup
        topic ABC-5-x-version-minor
        CGH_SKIP=1 git merge -q --no-ff -m Merge ABC-5-x-version-minor
        run "$sh_bin" "$HOOK" 0
        assert_rc 0 "$sh_bin"
        assert_contains "$(npm_calls)" 'version minor' "$sh_bin"
    done
}
