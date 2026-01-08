#!/bin/bash
set -euo pipefail

echo "=== Homebrew Maintenance ==="
echo

echo "Updating Homebrew..."
brew update

echo
echo "Upgrading packages..."
brew upgrade

echo
echo "Cleaning up old versions..."
brew cleanup

echo
echo "Checking for issues..."
brew doctor || true

echo
echo "=== Done ==="
