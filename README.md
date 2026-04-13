# Workstation Setup Scripts

A collection of bash scripts for provisioning a Mac development workstation from scratch. Each script is focused on a single concern and can be run independently or in sequence.

---

## setup_mac

The core provisioning script. It bootstraps Homebrew if not already installed — handling both Intel and Apple Silicon path differences automatically — then installs Homebrew formulae and VS Code extensions from two JSON manifests (`packages.json` and `extensions.json`). Only entries explicitly set to `true` in each manifest are acted on, making it easy to maintain a master list and toggle individual tools on or off per machine. It also writes a baseline `~/.vimrc` with syntax highlighting, mouse support, and relative line numbers.

The script is designed to be re-run safely: Homebrew installs are skipped if already present, and formula installs are gated on `brew list` to avoid redundant fetches. All failures are reported inline without aborting the run, so a single bad package won't block the rest of the setup.

---

## setup_git

An interactive script that writes a global Git configuration to `~/.gitconfig` via `git config --global`. It walks through a series of prompts — full name, GitHub email, GitHub username, default branch name, and preferred editor — and applies them all in one pass, finishing with a `git config --list --global` dump so you can confirm the result immediately. It also checks for the GitHub CLI (`gh`) upfront and warns if it's missing, since some remote workflows depend on it.

Because `git config --global` overwrites existing keys, the script is safe to re-run whenever identity or preferences need updating. Any values set by the script can also be overridden at any time with a direct `git config --global <key> <value>` call or by editing `~/.gitconfig` directly.

---

## setup_ohmyzsh

A non-interactive script that installs Oh My Zsh and applies a standard `~/.zshrc` configuration. It runs the official Oh My Zsh installer in unattended mode — suppressing the new shell spawn and preserving any existing `.zshrc` — then uses `sed` to patch in the `robbyrussell` theme and a predefined plugin list covering Docker, GitHub CLI, Helm, pip, 1Password, SSH, aws, sudo, kubectl, and kubectx. The install step is skipped if `~/.oh-my-zsh` already exists, and the `sed` patches are idempotent rewrites, making the script safe to re-run. Changes take effect after running `source ~/.zshrc`.

---

## .gitignore

While you're here, feel free to grab a copy of the `.gitignore` file (`gitignore.sample.txt`). It works well for most DevOps use cases!