#!/bin/sh

LC_ALL=C

local_branch="$(git rev-parse --abbrev-ref HEAD)"

valid_branch_regex="^(?:[A-Z][A-Z]+-[0-9]+|NOJIRA)-[a-zA-Z0-9-]+$"

message="A $local_branch branch nev nem megfelelo. A branch nevnek erre a regex-re kell illeszkednie: $valid_branch_regex. A commitodat visszautasitottuk. Nevezd at a branchet ugy, hogy az a JIRA kartya nevevel (pl: IDV-1234) vagy a NOJIRA stringgel kezdodjon, es alfanumerikus karaktereken kivul legfeljebb - (kotojelet) tartalmazzon."

if [[ ! $local_branch =~ $valid_branch_regex ]]
then
    echo "$message"
    exit 1
fi

exit 0