#!/bin/bash

osascript -e 'tell application "System Preferences" to quit'

# =============================================================================
# Dock
# =============================================================================

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock mru-spaces -bool false

# =============================================================================
# Finder
# =============================================================================

defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# =============================================================================
# Keyboard
# =============================================================================

defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# =============================================================================
# Trackpad
# =============================================================================

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# =============================================================================
# Screenshots
# =============================================================================

defaults write com.apple.screencapture location -string "${HOME}/Downloads"
defaults write com.apple.screencapture disable-shadow -bool true

# =============================================================================
# TextEdit
# =============================================================================

defaults write com.apple.TextEdit RichText -int 0

# =============================================================================
# Restart affected apps
# =============================================================================

killall Dock Finder SystemUIServer

echo "Done. Some changes may require a logout/restart to take effect."
