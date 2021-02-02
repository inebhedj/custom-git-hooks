# custom-git-hooks

Custom hook scripts to git based development

## What is it?

This scripts regenerates your `.git/hooks/` files to directory structure, and places your old hook files into this directories. After all, this script places some custom hooks into the new hook structure.

## Usage

Clone `custom-git-hooks` repository into your working repository (where you want to use **custom-git-hooks** services):

```bash
git clone git@github.com:velkeit/custom-git-hooks.git
```
(If you are not first time user, and you cloned before the **custom-git-hooks**, you may need to update your local instance: `git pull`.)

Start installation (or update) in CLI:

```bash
cd custom-git-hooks/
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

### 00-post-merge-master-npm-version

After a branch (with `-v100` or `-v010` or `-v001` on end of branch name -> name postfixum) merged into master, then this script bump npm package version, add git tag with new version and push into repository (if npm and package.json available in the repository's root).

The version bump based on the postfixum of the merged branch name (eg: `JIRA-1212-my-branch-v100`):

- **-v100** - version bump major (eg: v1.0.0 -> v2.0.0)
- **-v010** - version bump minor (eg: v1.1.0 -> v1.2.0)
- **-v001** - version bump patch (eg: v1.1.1 -> v1.1.2)

Original place is `custom-git-hooks/post-merge.d/00-post-merge-master-npm-version`.

New place after installation is `.git/hooks/post-merge.d/00-post-merge-master-npm-version`.
