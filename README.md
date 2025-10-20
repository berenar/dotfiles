# Bernat's dotfiles

This repository uses [stow](https://www.gnu.org/software/stow/stow.html) to manage dotfiles for various applications. Each application has its own directory containing the relevant configuration files.

It's inspired by [this blogpost](https://typecraft.dev/tutorial/never-lose-your-configs-again)

## How to use

1. Move your dotfiles into the respective application folder. For example, move `.vimrc` to `vim/.vimrc`.
1. Run $ stow <application> to create symlinks in your home directory. For example, run `stow vim` to symlink the Vim configuration files.
