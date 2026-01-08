#!/bin/zsh
set -euo pipefail

if [ ! -d "$HOME/.ssh" ]; then
    echo "create folder"
    mkdir "$HOME/.ssh"
fi

# create temp keys
curl -s https://github.com/llbbl.keys > "$HOME/.ssh/.logan_authorized_keys"

# if file exists
if [ -f "$HOME/.ssh/authorized_keys" ]; then
    isInFile=$(grep -c -f "$HOME/.ssh/.logan_authorized_keys" "$HOME/.ssh/authorized_keys" || true)

    if [ "$isInFile" -eq 0 ]; then
        echo "file appended"
        cat "$HOME/.ssh/.logan_authorized_keys" >> "$HOME/.ssh/authorized_keys"
    else
        echo "keys exist"
    fi
else
    echo "file created"
    mv "$HOME/.ssh/.logan_authorized_keys" "$HOME/.ssh/authorized_keys"
fi

rm -f "$HOME/.ssh/.logan_authorized_keys"

echo "fix permissions"
chmod go-rwx "$HOME/.ssh/authorized_keys"


