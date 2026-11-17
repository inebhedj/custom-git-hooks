#!/bin/sh
# Bumps the version in VERSION and package.json and prints the new version.
#
#   sh scripts/bump-version.sh major|minor|patch|release|X.Y.Z[-pre]
#
#   major | minor | patch   next version (refused while VERSION has a -pre suffix)
#   release                 drops the -pre suffix: 3.0.0-dev -> 3.0.0
#   X.Y.Z[-pre]             sets exactly this version

set -eu

root=$(cd "$(dirname "$0")/.." && pwd -P)
semver='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'

die() {
    echo "bump-version.sh: $*" >&2
    exit 1
}

[ $# -eq 1 ] || die "usage: bump-version.sh major|minor|patch|release|X.Y.Z[-pre]"

current=$(tr -d '[:space:]' <"$root/VERSION")
printf '%s\n' "$current" | grep -qE "$semver" || die "VERSION does not hold a version: '$current'"

base=${current%%-*}
pre=
case $current in *-*) pre=${current#*-} ;; esac

IFS=. read -r major minor patch <<EOF
$base
EOF

case $1 in
    major | minor | patch)
        [ -z "$pre" ] || die "$current is a pre-release; use 'release' or an explicit version"
        case $1 in
            major) new="$((major + 1)).0.0" ;;
            minor) new="$major.$((minor + 1)).0" ;;
            patch) new="$major.$minor.$((patch + 1))" ;;
        esac
        ;;
    release)
        [ -n "$pre" ] || die "$current is not a pre-release; use major, minor or patch"
        new=$base
        ;;
    *)
        printf '%s\n' "$1" | grep -qE "$semver" || die "not a version: '$1'"
        new=$1
        ;;
esac

printf '%s\n' "$new" >"$root/VERSION"

if [ -f "$root/package.json" ]; then
    tmp=$(mktemp) || exit 1
    trap 'rm -f "$tmp"' EXIT
    # package.json has a single "version" key
    sed "s/^\([[:space:]]*\"version\":[[:space:]]*\"\)[^\"]*\"/\1$new\"/" "$root/package.json" >"$tmp"
    cat "$tmp" >"$root/package.json"
fi

printf '%s\n' "$new"
