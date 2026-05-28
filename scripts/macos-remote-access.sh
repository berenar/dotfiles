#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# macOS remote access setup
# =============================================================================
#
# Configures a desktop-bound MacBook (lid closed, connected to an external
# display + AC power) so it's always reachable over SSH from a phone via
# Termius + Tailscale.
#
# Run this only on the desk machine, not on a laptop you carry around.
# Reverts cleanly: see the "Undo" section at the bottom of this file.
# =============================================================================

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

# -----------------------------------------------------------------------------
# Power management
# -----------------------------------------------------------------------------
#
# On AC:  never sleep, blank the display after 10 min.
# On battery: leave defaults (sleep ~1 min idle) — clamshell mode requires AC,
#             so a lid-closed laptop on battery sleeps no matter what we do.
#
# Why these flags only:
#   - sleep 0          system never idle-sleeps on AC
#   - displaysleep 10  blanks the Studio Display after 10 min (system stays up)
#   - everything else (powernap, tcpkeepalive, womp, standby) is either a
#     no-op when sleep=0 or irrelevant on Apple Silicon SSDs, so we skip them.
#
# Verify after running: `pmset -g custom` and `pmset -g assertions`. Look for
# the "Powerd - Prevent sleep while display is on" assertion to confirm
# clamshell mode is holding the system awake.
# -----------------------------------------------------------------------------

log "Configuring power management (AC: stay awake, battery: defaults)"
sudo pmset -c sleep 0 displaysleep 10

# -----------------------------------------------------------------------------
# SSH server (Remote Login)
# -----------------------------------------------------------------------------
# Termius connects over SSH, so the built-in SSH server must be on.
# -----------------------------------------------------------------------------

log "Enabling Remote Login (SSH server)"
sudo systemsetup -setremotelogin on >/dev/null

# -----------------------------------------------------------------------------
# Tailscale
# -----------------------------------------------------------------------------
# Gives the Mac a stable hostname reachable from anywhere without port
# forwarding. Termius uses the *.ts.net hostname or 100.x IP as the host.
# -----------------------------------------------------------------------------

if ! [ -d "/Applications/Tailscale.app" ] && ! command -v tailscale >/dev/null 2>&1; then
  log "Tailscale not installed — install with: brew install --cask tailscale-app"
  log "Then sign in via the menu bar app and re-run this script."
  exit 1
fi

if command -v tailscale >/dev/null 2>&1; then
  log "Tailscale status:"
  tailscale status --self --peers=false 2>/dev/null || tailscale status | head -5
fi

# -----------------------------------------------------------------------------
# Termius (phone-side)
# -----------------------------------------------------------------------------
# Nothing to install on the Mac. On the phone, add a host with:
#   Hostname: <this-mac>.<tailnet>.ts.net   (or the 100.x IP)
#   Username: $USER
#   Auth:     SSH key (upload your phone's public key to ~/.ssh/authorized_keys
#             on this Mac) — password auth is fine but keys are better.
# -----------------------------------------------------------------------------

log "Done. Summary:"
echo "  - AC:      sleep 0, displaysleep 10"
echo "  - Battery: defaults (sleeps when lid closed, as intended)"
echo "  - SSH:     Remote Login enabled"
echo "  - Network: reach this Mac at $(scutil --get LocalHostName).<tailnet>.ts.net via Tailscale"
echo
echo "Sanity check anytime:"
echo "  pmset -g custom"
echo "  pmset -g assertions | grep -i 'prevent sleep while display'"

# =============================================================================
# Undo
# =============================================================================
# To revert power management to defaults:
#   sudo pmset -c sleep 1 displaysleep 10
# To disable Remote Login:
#   sudo systemsetup -setremotelogin off
# =============================================================================
