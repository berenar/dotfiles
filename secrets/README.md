# Secrets Directory

This directory contains encrypted sensitive files that are safely backed up to git using [git-crypt](https://github.com/AGWA/git-crypt).

## Directory Structure

```
secrets/
├── .ssh/          # SSH keys and config
│   ├── id_ed25519
│   ├── id_ed25519.pub
│   ├── id_rsa
│   ├── id_rsa.pub
│   └── config
└── .aws/          # AWS credentials and config
    ├── config
    └── credentials
```

## Initial Setup (First Time)

1. Install git-crypt:
   ```bash
   brew install git-crypt
   ```

2. Initialize git-crypt in the repository:
   ```bash
   cd ~/dotfiles
   git-crypt init
   ```

3. Add your GPG key as a git-crypt collaborator (recommended):
   ```bash
   # If you don't have a GPG key yet, create one
   gpg --full-generate-key
   
   # Add your GPG key to git-crypt
   git-crypt add-gpg-user YOUR_GPG_KEY_ID
   ```
   
   Alternatively, you can export a symmetric key for backup:
   ```bash
   git-crypt export-key ~/dotfiles-key
   # Store this key file securely (password manager, encrypted drive, etc.)
   ```

4. Copy your sensitive files to the secrets directory:
   ```bash
   # SSH keys
   cp ~/.ssh/id_* secrets/.ssh/
   cp ~/.ssh/config secrets/.ssh/
   
   # AWS config
   cp ~/.aws/config secrets/.aws/
   cp ~/.aws/credentials secrets/.aws/
   ```

5. Commit and push the encrypted files:
   ```bash
   git add secrets/
   git commit -m "Add encrypted secrets"
   git push
   ```

## Restoring on a New Computer

### Method 1: Using GPG Key (Recommended)

1. Install git-crypt:
   ```bash
   brew install git-crypt
   ```

2. Ensure your GPG key is available on the new machine:
   ```bash
   # Import your GPG key if needed
   gpg --import your-private-key.asc
   ```

3. Clone the repository and unlock:
   ```bash
   git clone https://github.com/berenar/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   git-crypt unlock
   ```

### Method 2: Using Symmetric Key

1. Install git-crypt:
   ```bash
   brew install git-crypt
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/berenar/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. Unlock using the key file:
   ```bash
   git-crypt unlock /path/to/dotfiles-key
   ```

### Restore Files to Their Locations

After unlocking, use stow or manually copy files:

```bash
# Using stow (create symlinks)
cd ~/dotfiles
stow -t ~/ secrets

# Or manually copy files
cp secrets/.ssh/* ~/.ssh/
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
cp secrets/.aws/* ~/.aws/
```

## Checking Encryption Status

To verify which files are encrypted:

```bash
git-crypt status
```

To check if the repository is locked or unlocked:

```bash
git-crypt status -e
```

## Security Notes

- **Never commit unencrypted sensitive files** to the repository
- The `.gitattributes` file specifies which paths are encrypted
- Files are encrypted/decrypted transparently when git-crypt is unlocked
- Keep your GPG key or symmetric key file secure
- Consider using a password manager to store the symmetric key
- For GPG approach, backup your GPG private key securely

## Updating Secrets

After unlocking the repository, you can edit files normally:

```bash
cd ~/dotfiles
# Edit the files
vim secrets/.ssh/config
# Commit changes (they'll be encrypted automatically)
git add secrets/
git commit -m "Update SSH config"
git push
```

## Adding New Secret Paths

To encrypt additional files, edit `.gitattributes` and add patterns:

```
new-secret-path/** filter=git-crypt diff=git-crypt
```
