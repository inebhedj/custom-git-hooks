# shellcheck shell=sh
# Tests of scripts/bump-version.sh

# make_tree VERSION: a minimal tree with the script, VERSION and package.json
make_tree() {
    TREE=$(mktemp -d "$T_TMP/tree.XXXXXX")
    mkdir -p "$TREE/scripts"
    cp "$ROOT/scripts/bump-version.sh" "$TREE/scripts/"
    printf '%s\n' "$1" >"$TREE/VERSION"
    printf '{\n  "name": "x",\n  "version": "%s",\n  "license": "ISC"\n}\n' "$1" >"$TREE/package.json"
}

bump() {
    run sh "$TREE/scripts/bump-version.sh" "$1"
}

test_patch_minor_major() {
    make_tree 1.2.3
    bump patch && assert_rc 0 && assert_eq 1.2.4 "$OUT"
    bump minor && assert_rc 0 && assert_eq 1.3.0 "$OUT"
    bump major && assert_rc 0 && assert_eq 2.0.0 "$OUT"
    assert_eq 2.0.0 "$(cat "$TREE/VERSION")"
}

test_package_json_is_updated_and_the_rest_left_alone() {
    make_tree 1.2.3
    bump minor
    assert_eq '{
  "name": "x",
  "version": "1.3.0",
  "license": "ISC"
}' "$(cat "$TREE/package.json")"
}

test_release_drops_the_prerelease_suffix() {
    make_tree 3.0.0-dev
    bump release
    assert_rc 0
    assert_eq 3.0.0 "$OUT"
    assert_eq 3.0.0 "$(cat "$TREE/VERSION")"
}

test_a_prerelease_cannot_be_bumped_with_major_minor_patch() {
    make_tree 3.0.0-dev
    for b in major minor patch; do
        bump "$b"
        assert_rc 1 "$b"
        assert_contains "$OUT" 'pre-release'
    done
    assert_eq 3.0.0-dev "$(cat "$TREE/VERSION")"
}

test_release_needs_a_prerelease() {
    make_tree 1.0.0
    bump release
    assert_rc 1
}

test_an_explicit_version_is_set() {
    make_tree 1.0.0
    bump 4.5.6-rc.1
    assert_rc 0
    assert_eq 4.5.6-rc.1 "$(cat "$TREE/VERSION")"
    assert_contains "$(cat "$TREE/package.json")" '"version": "4.5.6-rc.1"'
}

test_garbage_is_refused_and_nothing_changes() {
    make_tree 1.0.0
    for b in nonsense 1.2 v1.2.3 ''; do
        bump "$b"
        assert_rc 1 "'$b'"
    done
    assert_eq 1.0.0 "$(cat "$TREE/VERSION")"
}

test_the_repository_versions_agree() {
    assert_eq "$(cat "$ROOT/VERSION")" "$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/package.json")" \
        "VERSION and package.json differ"
}
