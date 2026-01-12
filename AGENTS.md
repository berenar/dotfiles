# AGENTS.md

This file provides guidance for AI coding agents working in this repository.

---

## Repository Overview

This is a **macOS machine setup repository** containing:

- **Dotfiles** managed with [GNU Stow](https://www.gnu.org/software/stow/)
- **Packages** via Homebrew (Brewfile)
- **System preferences** via shell script

This is a **config-only repository** - there are no build steps, tests, or linting to run.

---

## Quick Reference Commands

### Package Management

```bash
# Install all packages from Brewfile
brew bundle

# Regenerate Brewfile from currently installed packages
brew bundle dump --force --no-restart --no-vscode
```

### Dotfiles Management

```bash
# Apply a dotfile package (creates symlinks to home directory)
stow <package>

# Remove a dotfile package
stow -D <package>

# Preview what stow would do (dry run)
stow -n -v <package>
```

### macOS Configuration

```bash
# Apply macOS system preferences
bash scripts/macos-config.sh
```

---

## Stow Package Structure

Each stow package is a directory at the repository root. The internal structure mirrors
the home directory layout.

### Current Packages

git, kitty, lazydocker, lazygit, nvim, opencode, ssh, tmux, zshrc

### Adding New Dotfiles

To add a new config file to the repository:

1. Create a directory matching the application name
2. Inside, recreate the path from home directory
3. Move the config file into this structure
4. Run `stow <package>` to create the symlink

Example: Adding `~/.config/foo/config.yml`

```
foo/
  .config/
    foo/
      config.yml
```

---

## Git Conventions

### Commit Message Format

This repository uses **conventional commits**.

---

## File Operations

### Deleting Files

Use `trash` instead of `rm` for safety (allows recovery):

```bash
# Preferred
trash ~/.config/old-app

# Only for dependencies
rm -rf node_modules
```

### Protected Files

Never modify these files directly:

- `.env` files (anywhere in the repo)
- `.zsh_secrets` (contains private tokens/keys)

---

## Sensitive Information

### Gitignored Files

These patterns are ignored and should stay that way:

```
.DS_Store
**/.env
.zsh_secrets
/lazygit/Library/Application Support/lazygit/state.yml
```

### Privacy Considerations

When adding configs that reference personal or work-related identifiers:

- Rename or anonymize identifiers before committing
- Use generic names (e.g., `clbrt-*` instead of full company names)

---

## Shell Script Style

Shell scripts in this repository follow these conventions:

### Format

- Shebang: `#!/bin/bash`
- Use `shfmt` for formatting (included in Brewfile)
- Section separators with comment blocks

---

## OpenCode Plugin Development

The `opencode/.config/opencode/` directory contains TypeScript plugins.

### Plugin Structure

```
opencode/.config/opencode/
  plugin/           # TypeScript plugins
  command/          # Custom slash commands (markdown)
  instructions/     # System instructions (markdown)
  opencode.jsonc    # Main configuration
```

### Plugin Style (TypeScript)

When modifying plugins:

- Use `async/await` over promise chains
- Use named imports: `import { foo } from "bar"`
- Use `const` over `let`
- No `any` type - use proper types or `unknown`
- No code comments

---

## Directory Structure

```
dotfiles/
  Brewfile              # Homebrew packages
  README.md             # User documentation
  scripts/
    macos-config.sh     # macOS system preferences
  git/                  # Stow package
  kitty/                # Stow package
  lazydocker/           # Stow package
  lazygit/              # Stow package
  nvim/                 # Stow package (LazyVim)
  opencode/             # Stow package (AI agent config)
  ssh/                  # Stow package
  tmux/                 # Stow package
  zshrc/                # Stow package
```
