# custom-git-hooks

Shared git hooks for JIRA-style workflows:

- **commit-msg:** puts the ticket of the branch name in front of the commit subject (`ABC-123: Fix it`, or `NOJIRA: …`).
- **pre-commit:** checks the branch name (`ABC-123-some-topic` or `NOJIRA-some-topic`) and asks for confirmation before a commit to `master` / `main`.
- **Several scripts per hook:** every hook runs the scripts of its `hooks.d/<hook>/` directory in order, so you can add your own next to ours.

The hooks are copied into **your repository's `.githooks/` directory** and activated with `core.hooksPath`. They are committed with your code, so the whole team runs the same version.

> **Upgrading from v1/v2?** See [Migrating](#migrating-from-v1v2). The old documentation is in [README-v2.md](README-v2.md).

## Install

Run the installer from the repository you want to set up (any clone of this repo will do; there is no need to keep it inside your project):

```sh
git clone https://github.com/velkeit/custom-git-hooks.git ~/tools/custom-git-hooks   # once
cd /path/to/your/project
sh ~/tools/custom-git-hooks/install.sh
git add .githooks && git commit
```

Teammates only need to enable the committed hooks after cloning (`install.sh` does the same, plus updates):

```sh
git config core.hooksPath .githooks
```

Options: `--dry-run` shows what would happen, `--uninstall` removes everything again, `--dir NAME` uses another directory than `.githooks`, `--force` takes over an existing `core.hooksPath`. Running the installer again updates the hooks; your `cgh.conf` and your own scripts are never overwritten.

## Configuration

`.githooks/cgh.conf` (one `key = value` per line). Every value can also be set with `git config cgh.<key-with-dashes>` or with the environment variable `CGH_<KEY>`, which take precedence.

| key | default | meaning |
|---|---|---|
| `ticket_regex` | `[A-Z][A-Z0-9]+-[0-9]+` | ERE matching a ticket key |
| `no_ticket` | `NOJIRA` | token used when there is no ticket |
| `branch_regex` | `^(<ticket>\|<no_ticket>)-[a-zA-Z0-9-]+$` | ERE every new branch name has to match |
| `protected_branches` | `master main` | space separated globs (`release/*`); `none` protects nothing |

## What the hooks do

**`commit-msg/00-jira-prefix`**: takes the ticket from the start of the branch name and prepends it to the commit subject. The body and comments are left alone. Nothing happens if the subject already starts with a ticket (a different one only gives a notice), for `fixup!`/`squash!` commits, merges, rebases, cherry-picks and a detached HEAD.

**`pre-commit/00-branch-name`**: a new branch (one without commits of its own) whose name does not match `branch_regex` is rejected, with a suggestion how to rename it. An old branch with a bad name only gets a notice.

**`pre-commit/10-protected-branch`**: asks `Are you sure you want to commit to master? (y/N)`. Without a terminal (IDE, scripts) the commit is rejected, unless you override it explicitly:

```sh
CGH_ALLOW_PROTECTED=1 git commit ...
```

### Skipping and debugging

- `git commit --no-verify` skips `pre-commit` and `commit-msg` as usual. Client-side hooks can always be bypassed, so enforce important rules in CI as well.
- `CGH_SKIP=1 git ...` skips all custom-git-hooks scripts for one command.
- `CGH_DEBUG=1 git ...` prints every script that is run.

## Adding your own hooks

Put an executable script into `.githooks/hooks.d/<hook-name>/` (for example `.githooks/hooks.d/pre-push/50-tests`) and run `install.sh` again, which creates the missing stub for that hook. Scripts run in lexical order and the first one that fails stops the hook. Files ending in `.sample`, `.backup` or `.disabled` are ignored. A script gets the hook's arguments and its standard input.

A hook that already existed in `.git/hooks/` when you installed keeps running after the custom scripts.

## Migrating from v1/v2

v1/v2 copied the hooks into `.git/hooks/` and kept the scripts in `.git/hooks/<hook>.d/`. Installing v3 switches to `core.hooksPath`, which makes git ignore `.git/hooks` completely, so:

1. Run `install.sh`. It tells you which old skeleton hooks it found.
2. Scripts you added yourself to `.git/hooks/<hook>.d/` are **not** run any more. Move them to `.githooks/hooks.d/<hook>/` and run `install.sh` again.
3. Delete the old `.git/hooks/*.d` directories and, if you like, the `custom-git-hooks/` lines from your `.gitignore`.
4. Not carried over: the `post-merge` version bump (it belonged in CI, not on every developer's machine; a CI workflow is planned) and the `postinstall-cgh.js` helper (an npm package is planned).

## Development

```sh
sh tests/run.sh               # all tests
sh tests/run.sh commit_msg    # one file: commit_msg, pre_commit, dispatch, install
```

The tests need only `git` and a POSIX shell; each runs in a fresh temporary repository and never touches your own git configuration. CI additionally runs `shellcheck` and checks the scripts with `dash`.

Layout: `install.sh` (installer), `payload/` (what gets copied: `_dispatch`, `lib.sh`, `cgh.conf`, `hooks.d/`), `tests/`, `data/` + `custom-git-hooks-install.sh` + `postinstall-cgh.js` (the old v2, to be removed).

## License

ISC, see [ISC-LICENSE.md](ISC-LICENSE.md).
