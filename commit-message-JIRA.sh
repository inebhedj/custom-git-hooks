#!/bin/sh

LC_ALL=C

local_branch="$(git rev-parse --abbrev-ref HEAD)"

jira_ticket=$(echo $local_branch | grep -e '^[A-Z][A-Z]\+-[0-9]\+\|NOJIRA' -o)

if ! grep -iqE "^$commit_regex" "$1"; then
    echo "$jira_ticket"': '$(cat "$1") > "$1"
fi

exit 0