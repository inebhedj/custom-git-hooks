# ih-cgh - ih custom git hooks

Shared git hooks for ticket-based workflows. The ticket key is JIRA-style (`ABC-123`) by default, but the pattern is configurable (see `ticket_regex` below), so it does not depend on JIRA:

- **commit-msg:** puts the ticket of the branch name in front of the commit subject (with the default settings `ABC-123: Fix it`, or `NOJIRA: …` when there is no ticket).
- **pre-commit:** checks the branch name (with the default settings `ABC-123-some-topic` or `NOJIRA-some-topic`) and asks for confirmation before a commit to `master` / `main`.
- **post-merge:** after `git merge` into `master` / `main`, a branch whose name ends with `-version-major|minor|patch|fix` bumps the npm version, tags it and pushes (Node projects).
- **Several scripts per hook:** every hook runs the scripts of its `hooks.d/<hook>/` directory in order, so you can add your own next to ours.

The hooks are copied into **your repository's `.githooks/` directory** and activated with `core.hooksPath`. They are committed with your code, so every clone runs the same version.

## Install

Run the installer from the repository you want to set up (any clone of this repo will do; there is no need to keep it inside your project):

```sh
git clone git@github.com:inebhedj/ih-cgh.git ~/tools/custom-git-hooks   # once
cd /path/to/your/project
sh ~/tools/custom-git-hooks/install.sh
git add .githooks && git commit
```

After cloning, the committed hooks only need to be enabled (`install.sh` does the same, plus updates):

```sh
git config core.hooksPath .githooks
```

### Node projects (npm)

Instead of cloning, add the package and let `npm install` set up the hooks:

```sh
npm install --save-dev github:inebhedj/ih-cgh
```

```json
{
  "scripts": {
    "prepare": "cgh prepare"
  }
}
```

`cgh prepare` installs quietly, does nothing on CI servers (`CI` is set), outside of git repositories or with `CGH_SKIP_INSTALL=1`, and never makes `npm install` fail. Other commands: `cgh install`, `cgh uninstall`, `cgh check`, `cgh version` (`npx cgh help`).

### Options

`--dry-run` shows what would happen, `--uninstall` removes everything again, `--dir NAME` uses another directory than `.githooks`, `--force` takes over an existing `core.hooksPath`. Running the installer again updates the hooks; your `cgh.conf` and your own scripts are never overwritten.

## Configuration

`.githooks/cgh.conf` (one `key = value` per line). Every value can also be set with `git config cgh.<key-with-dashes>` or with the environment variable `CGH_<KEY>`, which take precedence.

| key                  | default                                   | meaning                                                                 |
| -------------------- | ----------------------------------------- | ----------------------------------------------------------------------- |
| `ticket_regex`       | `[A-Z][A-Z0-9]+-[0-9]+`                   | ERE matching a ticket key                                               |
| `no_ticket`          | `NOJIRA`                                  | token used when there is no ticket                                      |
| `branch_regex`       | `^(<ticket>\|<no_ticket>)-[a-zA-Z0-9-]+$` | ERE every new branch name has to match                                  |
| `protected_branches` | `master main`                             | space separated globs (`release/*`); `none` protects nothing            |
| `version_branches`   | `master main`                             | space separated globs: a merge into these branches can bump the version |
| `version_push`       | `yes`                                     | `no`: do not push the version commit and tag                            |

## What the hooks do

**`commit-msg/00-jira-prefix`**: takes the ticket from the start of the branch name and prepends it to the commit subject. The body and comments are left alone. Nothing happens if the subject already starts with a ticket (a different one only gives a notice), for `fixup!`/`squash!` commits, merges, rebases, cherry-picks and a detached HEAD.

**`pre-commit/00-branch-name`**: a new branch (one without commits of its own) whose name does not match `branch_regex` is rejected, with a suggestion how to rename it. An old branch with a bad name only gets a notice.

**`pre-commit/10-protected-branch`**: asks `Are you sure you want to commit to master? (y/N)`. Without a terminal (IDE, scripts) the commit is rejected, unless you override it explicitly:

```sh
CGH_ALLOW_PROTECTED=1 git commit ...
```

**`post-merge/00-version-bump`**: after a `git merge` into `master` / `main` (see `version_branches`) it looks at the branches that point at the merged commit. If one of them ends with `-version-major`, `-version-minor`, `-version-patch` or `-version-fix` (the highest wins), it runs `npm version` (commit `NOJIRA: Releasing version X`, tag `vX`) and pushes the commit **and** the tag together (`git push --atomic`: both arrive or neither). If the push fails, the commit and tag stay local and the message tells you the command to retry.

```sh
git switch -c ABC-5-new-login-version-minor
git commit -m "..."
git switch master
git merge -
```

It needs a `package.json` and `npm`. It does **not** run after `git pull` (also not when you pull a merge that was made on GitHub; for that see [`templates/release-on-merge.yml`](templates/release-on-merge.yml), which does the same on the server; use the hook or the template, not both) and not for `git merge --squash`.

### Skipping and debugging

- `git commit --no-verify` skips `pre-commit` and `commit-msg` as usual. Client-side hooks can always be bypassed, so enforce important rules in CI as well.
- `CGH_SKIP=1 git ...` skips all custom-git-hooks scripts for one command.
- `CGH_DEBUG=1 git ...` prints every script that is run.

## Adding your own hooks

Put an executable script into `.githooks/hooks.d/<hook-name>/` (for example `.githooks/hooks.d/pre-push/50-tests`) and run `install.sh` again, which creates the missing stub for that hook. Scripts run in lexical order and the first one that fails stops the hook. Files ending in `.sample`, `.backup` or `.disabled` are ignored. A script gets the hook's arguments and its standard input.

A hook that already existed in `.git/hooks/` when you installed keeps running after the custom scripts.

## Checking on the server

Client-side hooks can be skipped, so `install.sh` also puts `.githooks/cgh-check` into your repository (`cgh check` from npm). It checks the branch name and the subject of every commit in `BASE..HEAD` with the same configuration as the hooks:

```sh
sh .githooks/cgh-check --base origin/main --branch "$BRANCH"
```

Exit status 0 means fine, 1 means something is wrong. A ready-to-copy GitHub workflow is in [`templates/check-pull-request.yml`](templates/check-pull-request.yml). The files in `templates/` are **not active**; nothing in this repository starts automatically.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

ISC, see [ISC-LICENSE.md](ISC-LICENSE.md).
