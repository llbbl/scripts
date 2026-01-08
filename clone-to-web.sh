#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: clone-to-web.sh <repo>"
    echo "Examples:"
    echo "  clone-to-web.sh owner/repo"
    echo "  clone-to-web.sh git@github.com:owner/repo.git"
    echo "  clone-to-web.sh https://github.com/owner/repo"
    exit 1
fi

REPO="$1"
WEB_DIR="$HOME/Web"

cd "$WEB_DIR"

# Clone using gh if it looks like owner/repo format, otherwise git clone
if [[ "$REPO" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
    echo "Cloning $REPO to $WEB_DIR..."
    gh repo clone "$REPO"
    REPO_NAME="${REPO##*/}"
else
    echo "Cloning $REPO to $WEB_DIR..."
    git clone "$REPO"
    # Extract repo name from URL
    REPO_NAME=$(basename "$REPO" .git)
fi

echo
echo "Cloned to: $WEB_DIR/$REPO_NAME"
echo "Run: cd $WEB_DIR/$REPO_NAME"
