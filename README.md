# Bernat's dotfiles

This repository uses [stow](https://www.gnu.org/software/stow/stow.html) to manage dotfiles for various applications. Each application has its own directory containing the relevant configuration files.

This set up is inspired by [this blogpost](https://typecraft.dev/tutorial/never-lose-your-configs-again).

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/stow.html) (for managing the dotfile symlinks)
- [Homebrew](https://brew.sh/) (for managing packages with the included Brewfile)

## How to use

1. Move your dotfiles into the respective application folder with the same name. For example, move `.config/nvim/` to `nvim/.config/nvim/`.
1. Run Create symlinks in your home directory. For example, run `stow vim` to symlink the Vim configuration files.
   ```bash
   stow <application>
   ```

## Brewfile

This repository also includes a `Brewfile` for managing packages using Homebrew.
The casks list assumes you use MacOS.

To install the packages listed in the `Brewfile`, run the following command:

```bash
brew bundle --file=Brewfile
```

To regenerate the `Brewfile` with your currently installed packages:

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force --no-restart --no-vscode
```
