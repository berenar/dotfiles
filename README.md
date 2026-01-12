# Bernat's dotfiles, packages & config

This repository aims to make the setup of a new machine extremely easy. It contains everything needed to set it up:

- Packages via Homebrew.
- Dotfiles managed with [stow](https://www.gnu.org/software/stow/stow.html).
- System preferences for macOS via a simple shell script.

This set up was inspired by [this blogpost](https://typecraft.dev/tutorial/never-lose-your-configs-again).

## Requirements

- [Homebrew](https://brew.sh/) for managing packages.
- [GNU Stow](https://www.gnu.org/software/stow/stow.html) for managing the dotfile symlinks (this is included in the `Brewfile`).

## Packages

This repository includes a `Brewfile` for managing packages using Homebrew.
The casks list assumes you use macOS.

To install the packages listed, run the following command from the directory containing the `Brewfile`:

```bash
brew bundle
```

To regenerate the `Brewfile` with your currently installed packages:

```bash
brew bundle dump --force --no-restart --no-vscode
```

## Dotfiles

- To add new dotfiles: move them into a folder matching the application name (e.g., `.config/nvim/` → `nvim/.config/nvim/`).
- To apply existing dotfiles: run `stow <application>` to create symlinks in your home directory.

```bash
stow <application>
```

## macOS Configuration

This repository includes a script to apply preferred macOS system settings.

To apply the settings:

```bash
bash scripts/macos-config.sh
```
