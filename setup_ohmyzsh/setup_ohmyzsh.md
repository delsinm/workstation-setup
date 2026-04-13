# setup_ohmyzsh.sh

A non-interactive script that installs Oh My Zsh and applies a baseline `~/.zshrc` configuration — setting the theme and enabling a curated plugin list — in a single run. Safe to re-run against an existing Oh My Zsh installation.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| `zsh` | Must be installed and available on `$PATH` |
| `curl` | Used to fetch the Oh My Zsh installer |
| `sed` | Used to patch `~/.zshrc`; pre-installed on macOS |
| `~/.zshrc` | Must already exist — created automatically by the Oh My Zsh installer on first run |

---

## Usage

```bash
chmod +x setup_ohmyzsh.sh
./setup_ohmyzsh.sh
```

No prompts. After the script completes, reload your shell config to apply changes:

```bash
source ~/.zshrc
```

---

## What It Does

### 1. Oh My Zsh install
Checks for an existing `~/.oh-my-zsh` directory. If found, the install step is skipped entirely. If not, fetches and runs the official installer from `raw.githubusercontent.com/ohmyzsh/ohmyzsh` with two environment flags:

- `--unattended` — runs without any interactive prompts
- `RUNZSH=no` — prevents the installer from immediately spawning a new `zsh` session, which would stall the rest of the script
- `KEEP_ZSHRC=yes` — prevents the installer from overwriting an existing `~/.zshrc`

### 2. Theme
Patches the `ZSH_THEME` line in `~/.zshrc` to `robbyrussell` (the Oh My Zsh default theme) using `sed`. The regex targets any existing theme value (`ZSH_THEME=".*"`) so it works regardless of what was previously set.

### 3. Plugins
Replaces the entire `plugins=(...)` line in `~/.zshrc` with the following set:

| Plugin | Purpose |
|---|---|
| `docker` | Aliases and completions for Docker CLI |
| `gh` | Completions for the GitHub CLI |
| `helm` | Completions for Helm |
| `pip` | Completions for Python's pip |
| `1password` | Shell integration for the 1Password CLI |
| `ssh` | SSH agent and key management helpers |
| `kubectl` | Aliases and completions for kubectl |
| `kubectx` | Completions for kubectx/kubens |
| `aws` | Completions and helpers for the AWS CLI |
| `terraform` | Completions for Terraform commands and subcommands |
| `minikube` | Completions for local Kubernetes cluster management |
| `sudo` | Double-tap `Esc` to prepend `sudo` to the current or previous command |
| `history` | Adds aliases like `h` for searching history with improved defaults |
| `git` | Extensive set of Git aliases and helper functions |

The `sed` command targets the line starting with `plugins=(` and replaces the entire contents. Any previously enabled plugins are overwritten.

### 4. Prompt
Appends a custom `PROMPT` to `~/.zshrc` using a heredoc, overriding the robbyrussell default with a version that displays the full working path (`%~`) in bold white:

```bash
PROMPT='${ret_status} %{$fg_bold[white]%}%~%{$reset_color%} $(git_prompt_info)'
```

The structure mirrors robbyrussell exactly — status indicator, path, git info — with `$fg_bold[white]` replacing the theme's default cyan for the path color. The append is gated on a `grep -qF 'PROMPT='` check so it is only written once. To change the color, swap `white` for any [zsh color name](https://wiki.zshell.dev/docs/guides/colors).

---

## Idempotency

The script is fully idempotent and safe to re-run across all four steps. The Oh My Zsh install is gated on the existence of `~/.oh-my-zsh`. The `sed` patches in steps 2 and 3 are deterministic rewrites. Step 4 is gated on a `grep -qF 'PROMPT='` check — if a `PROMPT=` line is already present in `~/.zshrc`, the append is skipped entirely.

---

## Modifying Plugins and Theme

To change the theme or plugin list, edit the variables directly in the script before running, or update `~/.zshrc` manually afterwards.

**Changing the theme** — replace `robbyrussell` with any theme name from the [Oh My Zsh theme list](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes):

```bash
# In ~/.zshrc
ZSH_THEME="agnoster"
```

**Adding or removing plugins** — edit the `TARGET_PLUGINS` variable in the script:

```bash
TARGET_PLUGINS="docker gh helm pip 1password ssh kubectl kubectx aws terraform minikube sudo history git"
```

Or edit the `plugins` line in `~/.zshrc` directly:

```bash
# In ~/.zshrc
plugins=(docker gh helm pip 1password ssh kubectl kubectx aws terraform minikube sudo history git)
```

Note that third-party plugins (e.g. `zsh-autosuggestions`, `zsh-syntax-highlighting`) must be cloned into `$ZSH_CUSTOM/plugins/` before they can be enabled. Built-in Oh My Zsh plugins work out of the box.

---

## Exit Behavior

The script has no explicit error handling and does not use `set -e`. If `curl` fails or `sed` finds no matching line in `~/.zshrc`, the script will complete without surfacing a failure. If the theme or plugins do not appear to have applied after `source ~/.zshrc`, inspect `~/.zshrc` directly to verify the `sed` substitutions landed correctly.
