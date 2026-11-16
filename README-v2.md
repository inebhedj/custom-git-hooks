# custom-git-hooks

Custom hook scripts to git based development

- [custom-git-hooks](#custom-git-hooks)
  - [What is it?](#what-is-it)
  - [Usage](#usage)
    - [Method 1: traditional "manual" installation](#method-1-traditional-manual-installation)
    - [Method 2: Helper module for nodejs based repositories](#method-2-helper-module-for-nodejs-based-repositories)
  - [Custom hooks in this repository](#custom-hooks-in-this-repository)
    - [commit-msg.d/00-commit-msg-jira-include-*](#commit-msgd00-commit-msg-jira-include-)
    - [post-merge.d/00-post-merge-master-main-npm-version-*](#post-merged00-post-merge-master-main-npm-version-)
    - [pre-commit-d/00-pre-commit-jira-branchname-*](#pre-commit-d00-pre-commit-jira-branchname-)

## What is it?

This scripts regenerates your `.git/hooks/` files to directory structure, and places your old hook files into this directories. After all, this script places some custom hooks into the new hook structure.

## Usage

You have two methods to use Custom-git-hooks in your project.
### Method 1: traditional "manual" installation

Clone `custom-git-hooks` repository into your working repository (where you want to use **custom-git-hooks** services):

```bash
git clone git@github.com:velkeit/custom-git-hooks.git
```
(If you are not a first time user, and you cloned before the **custom-git-hooks**, you may need to update your local instance: `git pull`.)

Start installation (or update) in CLI:

```bash
cd custom-git-hooks/
sh custom-git-hooks-install.sh
```
### Method 2: Helper module for nodejs based repositories

There is a file called `postinstall-cgh.js` at the root of this project. This script clone, pull, and install the Custom-git-hooks project into your repository.

**Prerequisites**: Helper module depends on `git-clone` and `git-pull` packages, so you need to install these packages into your project:

```sh
npm install --save-dev git-clone git-pull
```

**Next step**: download a copy this [`postinstall-cgh.js`](./postinstall-cgh.js) into your repository's root folder to support the postinstall process.

**Next step**: Copy lines above into your `postinstall` javascript file (in your project's root):

```javascript
require('./postinstall-cgh')(
  process.argv
    .map((item) => {
      return item.match(
        /^cgh:[clone|cloneonly|install|installonly|pull|pullonly]/gi
      )
        ? item.replace(/^cgh:/gi, '').toLowerCase()
        : false;
    })
    .filter((item) => item !== false)
);
```

Available Custom-git-hooks related postinstall attributes after modification above:

- **`cgh:clone`**        - **default:** clone (or pull if exists in local) repository and install / update Custom-git-hooks (eg: `node postinstall.js cgh:clone`)
- **`cgh:cloneonly`**    - only clone (if not exists in local) repository (eg: `node postinstall.js cgh:cloneonly`)
- **`cgh:install`**      - install / update Custom-git-hooks (or clone before, if repository not exists in local) (eg: `node postinstall.js cgh:install`)
- **`cgh:installonly`**  - only install / update Custom-git-hooks (if repository exists in local) (eg: `node postinstall.js cgh:installonly`)
- **`cgh:pull`**         - pull (or clone before if not exists in local) repository and install / update Custom-git-hooks (eg: `node postinstall.js cgh:pull`)
- **`cgh:pullonly`**     - only pull (if exists in local) repository (eg: `node postinstall.js cgh:pullonly`)

## Custom hooks in this repository

This installation places some custom hooks into the new hook structure. All script file names have a hyphens and a number at the end. This is script file version number, what help to installation process to hold or to remove script files on update. The script file version number does not increase linearly, because this number based on this repository's release version number. The wildcarded names below are samples, eg: `00-commit-msg-jira-include-*` is a possible reference to `00-commit-msg-jira-include-2`.


### commit-msg.d/00-commit-msg-jira-include-*

This script inserts  (eg.) the JIRA card name (eg: "JIRA-1212: ") or "NOJIRA: " string from branch name into commit message (to the beginning), if JIRA card name or NOJIRA string not presents in commit message (at the beginning).

Original place is `custom-git-hooks/commit-msg.d/00-commit-msg-jira-include-*`.

New place after installation is `.git/hooks/commit-msg.d/00-commit-msg-jira-include-*`.

### post-merge.d/00-post-merge-master-main-npm-version-*

After a branch (with `-version-major` or `-version-minor` or `-version-patch` or `-version-fix` on end of branch name -> name postfixum) merged into **master** or **main**, then this script bump npm package version, add git tag with new version and push into repository (if npm and package.json available in the repository's root).

The version bump based on the postfixum of the merged branch name (eg: `JIRA-1212-my-branch-version-major`):

- **-version-major** - version bump major (eg: v1.1.1 -> v2.0.0)
- **-version-minor** - version bump minor (eg: v1.0.1 -> v1.2.0)
- **-version-patch** - version bump patch (eg: v1.0.0 -> v1.0.1)
- **-version-fix** - version bump patch (eg: v1.0.0 -> v1.0.1)

Original place is `custom-git-hooks/post-merge.d/00-post-merge-master-main-npm-version-*`.

New place after installation is `.git/hooks/post-merge.d/00-post-merge-master-main-npm-version-*`.

### pre-commit-d/00-pre-commit-jira-branchname-*

This hook script checks (eg.) the JIRA card name (eg: JIRA-1212) or "NOJIRA" string at beginning of the branch name, and recejts commit, if not presents. This script asks for confirmation if wants to commit into **master** or **main**.

Original place is `custom-git-hooks/pre-commit.d/00-pre-commit-jira-branchname-*`.

New place after installation is `.git/hooks/pre-commit.d/00-pre-commit-jira-branchname-*`.
