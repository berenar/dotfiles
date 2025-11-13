# Bernat's dotfiles

This repository uses [stow](https://www.gnu.org/software/stow/stow.html) to manage dotfiles for various applications. Each application has its own directory containing the relevant configuration files.

This set up is inspired by [this blogpost](https://typecraft.dev/tutorial/never-lose-your-configs-again).

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/stow.html) (for managing the dotfile symlinks)
- [Homebrew](https://brew.sh/) (for managing packages with the included Brewfile)
- [git-crypt](https://github.com/AGWA/git-crypt) (optional, for encrypted secrets backup)

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

## Secure Secrets Backup

This repository includes support for **securely backing up sensitive files** like SSH keys and AWS credentials using [git-crypt](https://github.com/AGWA/git-crypt).

### Quick Start

1. Install git-crypt (included in Brewfile):
   ```bash
   brew install git-crypt
   ```

2. Initialize git-crypt with your GPG key:
   ```bash
   git-crypt init
   git-crypt add-gpg-user YOUR_GPG_KEY_ID
   ```

3. Copy your sensitive files to the `secrets/` directory:
   ```bash
   cp ~/.ssh/id_* secrets/.ssh/
   cp ~/.aws/{config,credentials} secrets/.aws/
   ```

4. Commit and push (files are encrypted automatically):
   ```bash
   git add secrets/
   git commit -m "Add encrypted secrets"
   git push
   ```

For detailed instructions on setup, restoration on new machines, and usage, see [secrets/README.md](secrets/README.md).
