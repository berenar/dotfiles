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

Dotfiles are stored in the `dotfiles/` subdirectory and managed with GNU Stow.

## Dotfiles Packages

This repository manages the following dotfiles packages:

- [kitty](https://github.com/kovidgoyal/kitty) - A fast, feature-rich, and GPU-based terminal emulator.
- [lazydocker](https://github.com/jesseduffield/lazydocker) - A simple terminal UI for Docker.
- [lazygit](https://github.com/jesseduffield/lazygit) - A simple terminal UI for Git.
- [nvim](https://github.com/neovim/neovim) - Hyperextensible Vim-based text editor.
- [tmux](https://github.com/tmux/tmux) - A terminal multiplexer.
- [opencode](https://github.com/anomalyco/opencode) - The open source AI coding agent.

### Add

To add new dotfiles, move them into `dotfiles/<app>/` matching the application name (e.g., `.config/nvim/` → `dotfiles/nvim/.config/nvim/`).

### Apply

To apply existing dotfiles: run the stow command to create symlinks in your home directory.

```bash
stow -d dotfiles -t ~ <application>
```

## macOS Configuration

This repository includes a script to apply preferred macOS system settings.

To apply the settings:

```bash
bash scripts/macos-config.sh
```
