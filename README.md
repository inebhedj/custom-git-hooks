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

### 00-commit-msg-jira-include

This script inserts  (eg.) the JIRA card name (eg: "JIRA-1212: ") or "NOJIRA: " string from branch name into commit message (to the beginning), if JIRA card name or NOJIRA string not presents in commit message (at the beginning).

Original place is `custom-git-hooks/commit-msg.d/00-pre-commit-jira-branchname`.

New place after installation is `.git/hooks/commit-msg.d/00-commit-msg-jira-include`.

### 00-post-merge-master-main-npm-version

After a branch (with `-version-major` or `-version-minor` or `-version-patch` or `-version-fix` on end of branch name -> name postfixum) merged into **master** or **main**, then this script bump npm package version, add git tag with new version and push into repository (if npm and package.json available in the repository's root).

The version bump based on the postfixum of the merged branch name (eg: `JIRA-1212-my-branch-version-major`):

- **-version-major** - version bump major (eg: v1.0.0 -> v2.0.0)
- **-version-minor** - version bump minor (eg: v1.1.0 -> v1.2.0)
- **-version-patch** - version bump patch (eg: v1.1.1 -> v1.1.2)
- **-version-fix** - version bump patch (eg: v1.1.1 -> v1.1.2)

Original place is `custom-git-hooks/post-merge.d/00-post-merge-master-main-npm-version`.

New place after installation is `.git/hooks/post-merge.d/00-post-merge-master-main-npm-version`.

## 00-post-receive-cgh-variables-file-remove

Remove temporary configuration file (what created by **00-pre-receive-cgh-variables-to-file script**).

Original place is `custom-git-hooks/post-receive.d/00-post-receive-cgh-variables-file-remove`.

New place after installation is `.git/hooks/post-receive.d/00-post-receive-cgh-variables-file-remove`.

### 00-pre-commit-jira-branchname

This hook script checks (eg.) the JIRA card name (eg: JIRA-1212) or "NOJIRA" string at beginning of the branch name, and recejts commit, if not presents. This script asks for confirmation if wants to commit into **master** or **main**.

Original place is `custom-git-hooks/pre-commit.d/00-pre-commit-jira-branchname`.

New place after installation is `.git/hooks/pre-commit.d/00-pre-commit-jira-branchname`.

## 00-pre-receive-cgh-variables-to-file

This hook script collects and writes all available global values about the current git flow to temporary configuration file. This file used by mostly other hook scripts.

Original place is `custom-git-hooks/pre-receive.d/00-pre-receive-cgh-variables-to-file`.

New place after installation is `.git/hooks/pre-receive.d/00-pre-receive-cgh-variables-to-file`.