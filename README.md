# git-hooks

Hook scripts to git based development

## commit-msg

The commit message checker / modifier scripts

### commit-message-JIRA.sh

This script inserts eg. JIRA card name or NOJIRA string from branch name into commit message (to the beginning), if JIRA card name or NOJIRA string not presents in comit message (at the beginning).

Based on _pre-commit/branch-name-checker-JIRA.sh_.

Place the code from _commit-message-JIRA.sh_ into `.git/hook/commit-msg` file in your repository.

## pre-commit

The branch name checker scripts

### pre-commit/branch-name-checker-JIRA.sh

This script checks eg. JIRA card name or NOJIRA string at beginning of the branch name, and recejt commit, if not presents.
