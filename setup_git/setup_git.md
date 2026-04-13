# setup_git.sh

An interactive script that writes a baseline Git global config via `git config --global`. It prompts for user identity and preferences, applies them in a single pass, and prints the resulting global config on completion. Optionally integrates with the GitHub CLI for remote workflows.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| `git` | Required — script exits with an error if not found |
| `gh` (GitHub CLI) | Optional but recommended; script warns and prompts to continue if absent |

---

## Usage

```bash
chmod +x setup_git.sh
./setup_git.sh
```

The script is fully interactive — no flags or arguments. All values are collected at runtime via prompted input.

---

## Prompts

| Prompt | Config Key | Default |
|---|---|---|
| Full name | `user.name` | none — required |
| GitHub email | `user.email` | none — required |
| GitHub username | `github.user` | none — required |
| Default branch name | `init.defaultBranch` | `main` |
| Preferred text editor | `core.editor` | `nano` |

Prompts with defaults will use the default value if you press Enter without typing anything.

---

## What It Does

### 1. Dependency checks
Verifies `git` is on `$PATH` — exits immediately with a non-zero code and an install hint if not found. Then checks for the `gh` CLI. If `gh` is absent, a warning is printed and you are prompted whether to continue; entering anything other than `y`/`Y` aborts the script.

### 2. Interactive prompts
Collects identity and preference values via `read -p`. The branch name and editor prompts use shell parameter expansion (`${var:-default}`) to fall back to `main` and `nano` respectively if no input is given.

### 3. Applying config
Writes the following keys to the global Git config (`~/.gitconfig`) in a single batch:

```
user.name            → your full name
user.email           → your GitHub email
github.user          → your GitHub username
init.defaultBranch   → default branch for git init (e.g. main)
core.editor          → editor opened for commit messages, rebases, etc.
color.ui             → set to auto (enables terminal colour output)
```

All writes use `git config --global`, so they apply across every repo on the machine and do not touch any per-repo `.git/config`.

### 4. Config dump
Runs `git config --list --global` on completion, printing every key currently in `~/.gitconfig` so you can verify the applied values at a glance.

---

## Idempotency

The script is safe to re-run. `git config --global` overwrites existing keys rather than appending, so running it again simply updates values to whatever you enter at the prompts. No state accumulates between runs.

---

## Exit Behavior

The script exits early with `exit 1` in two cases: `git` is not found, or the `gh` warning prompt receives a non-`y` response. Outside of those gates, all `git config` commands are run unconditionally and the script does not check for or surface individual command failures.

---

## Modifying the Config After the Fact

Any value set by this script can be viewed or overridden at any time without re-running it:

```bash
# View a specific key
git config --global user.name

# Update a specific key
git config --global core.editor vim

# Open ~/.gitconfig directly in your editor
git config --global --edit
```

To add config keys not covered by this script, use the same `git config --global <key> <value>` pattern or edit `~/.gitconfig` directly.
