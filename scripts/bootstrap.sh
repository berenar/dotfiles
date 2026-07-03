#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

log "brew bundle"
brew bundle --file "$REPO_DIR/Brewfile"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found after brew bundle; aborting" >&2
  exit 1
fi

log "Generating Codex AGENTS.md from shared instructions"
bash "$REPO_DIR/scripts/build-codex-agents-md.sh"

log "Stowing all packages"
cd "$REPO_DIR/dotfiles"
for pkg in */; do
  stow -t "$HOME" "${pkg%/}"
done
cd "$REPO_DIR"

if ! [ -x "$HOME/.local/bin/claude" ]; then
  log "Installing Claude Code CLI"
  curl -fsSL https://claude.ai/install.sh | bash
fi

log "Setting up Claude config dirs (claude-mvst, claude-clbrt)"
CLAUDE_SRC="$REPO_DIR/dotfiles/claude/.claude"
for dir in "$HOME/.claude-mvst" "$HOME/.claude-clbrt"; do
  mkdir -p "$dir"
  for item in CLAUDE.md commands hooks instructions keybindings.json settings.json skills; do
    ln -sfn "$CLAUDE_SRC/$item" "$dir/$item"
  done
done

log "Fixing SSH config permissions"
if [ -e "$HOME/.ssh/config" ]; then
  chmod 600 "$HOME/.ssh/config"
fi
chmod 700 "$HOME/.ssh" 2>/dev/null || true

log "Restarting tmux server (if running)"
tmux kill-server 2>/dev/null || true

log "Applying macOS defaults"
bash "$REPO_DIR/scripts/macos-config.sh"

log "Done. Open a new shell and start tmux; press prefix + I inside tmux to install plugins if TPM hasn't already."
