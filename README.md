# custom-git-hooks

Custom hook scripts to git based development

## What is it?

This scripts regenerates your `.git/hooks/` files to directory structure, and places your old hook files into this directories. After all, this script places some custom hooks into the new hook structure.

## Usage

Place `custom-git-hooks-install.sh` file and `custom-git-hooks/` directory (with all subdirectories and files) into your repository.

Start installation in CLI:
```bash
sh custom-git-hooks-install.sh
```

## Custom hooks in this repository

This installation places some custom hooks into the new hook structure.

### 00-pre-commit-jira-branchname

This hook script checks (eg.) the JIRA card name (eg: JIRA-1212) or "NOJIRA" string at beginning of the branch name, and recejts commit, if not presents.

Original place is `custom-git-hooks/pre-commit.d/00-pre-commit-jira-branchname`.

New place after installation is `.git/hooks/pre-commit.d/00-pre-commit-jira-branchname`.

### 00-commit-msg-jira-include

This script inserts  (eg.) the JIRA card name (eg: "JIRA-1212: ") or "NOJIRA: " string from branch name into commit message (to the beginning), if JIRA card name or NOJIRA string not presents in commit message (at the beginning).

Original place is `custom-git-hooks/commit-msg.d/00-pre-commit-jira-branchname`.

New place after installation is `.git/hooks/commit-msg.d/00-commit-msg-jira-include`.
