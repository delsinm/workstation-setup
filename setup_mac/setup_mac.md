# setup_mac.sh

A declarative, idempotent Mac provisioning script that bootstraps a workstation environment from two JSON config files. It handles Homebrew, formula installs, editor configuration, and VS Code extensions in a single pass.

---

## Prerequisites


| Requirement                    | Notes                                                                     |
| ------------------------------ | ------------------------------------------------------------------------- |
| macOS (Intel or Apple Silicon) | Architecture is detected automatically                                    |
| `python3`                      | Pre-installed on macOS; used to parse JSON config files                   |
| `packages.json`                | Homebrew formulae manifest — must be in the same directory as the script  |
| `extensions.json`              | VS Code extensions manifest — must be in the same directory as the script |


The script must be run from the directory containing both JSON files.

---

## Usage

```bash
chmod +x setup_mac.sh
./setup_mac.sh
```

No flags or arguments. All configuration is driven by the JSON manifests.

---

## Config Files

Both config files follow the same schema: a flat JSON object where each key is a package/extension identifier and the value is a boolean. Only entries set to `true` are acted on — set a value to `false` to skip it without removing it from the file.

`**packages.json**`

```json
{
  "git":     true,
  "ripgrep": true,
  "ffmpeg":  false
}
```

`**extensions.json**`

```json
{
  "esbenp.prettier-vscode":        true,
  "dbaeumer.vscode-eslint":        true,
  "vscodevim.vim":                 false
}
```

---

## What It Does

### 1. Homebrew bootstrap

Checks for a `brew` binary on `$PATH`. If absent, pulls and runs the official Homebrew install script from `https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh`. After install, the correct `shellenv` is evaluated based on architecture — `/opt/homebrew` on Apple Silicon, `/usr/local` on Intel — so subsequent `brew` calls in the same session work immediately.

### 2. Homebrew formula installs

Parses `packages.json` via an inline `python3` one-liner and builds a space-separated list of formulae where the value is `true`. For each formula, `brew list --formula` is grepped with `-x` (exact/whole-line match) to determine if it is already installed. Already-installed formulae are skipped with a success message; others are installed with `brew install --quiet`. Failures are reported per-package and do not abort the run.

### 3. `.vimrc` generation

Writes a baseline Vim config to `$HOME/.vimrc` using a quoted heredoc (`<< 'EOF'`), which prevents any shell interpolation of the Vim script content. The generated config enables syntax highlighting, mouse support, absolute line numbers, and relative line numbers. **This step always runs and will overwrite an existing `~/.vimrc`.**

### 4. VS Code extension installs

Requires both the `code` CLI to be on `$PATH` and `extensions.json` to be present — if either is missing the step is skipped or an error is printed accordingly. Parses `extensions.json` with the same `python3` pattern as step 2, then calls `code --install-extension <id> --force` for each enabled extension. stdout/stderr from `code` are suppressed; the script reports its own success/error per extension.

---

## Idempotency

The script is safe to re-run. Homebrew is only installed if missing, and formula installs are gated on `brew list` so already-installed packages are never re-fetched. VS Code extensions installed with `--force` are a no-op if the extension is already at the latest version. The only non-idempotent step is `.vimrc` generation, which unconditionally overwrites the file.

---

## Exit Behavior

The script does not use `set -e` and will not abort on a failed package or extension install. All errors are surfaced inline via `print_error` and the run continues. There is no non-zero exit code on partial failure — if this matters for CI use, wrap the script or add explicit exit code tracking.

---

## Extending the Script

To add new provisioning steps, follow the existing pattern: add a numbered comment block, use `print_status` / `print_success` / `print_error` for output, and keep each step self-contained so failures don't cascade.