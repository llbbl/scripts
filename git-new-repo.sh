#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: git-new-repo.sh <github-repo-url>"
    echo "Example: git-new-repo.sh git@github.com:user/repo.git"
    exit 1
fi

REMOTE_URL="$1"

# Check if already a git repo
if [ -d .git ]; then
    echo "Already a git repository"
    exit 1
fi

echo "Initializing git repository..."
git init

echo "Adding remote origin..."
git remote add origin "$REMOTE_URL"

echo "Creating initial commit..."
git add .
git commit -m "Initial commit"

echo "Setting branch to main..."
git branch -M main

echo
echo "Ready to push with: git push -u origin main"
