#!/bin/zsh
set -euo pipefail

ssh_dir="$HOME/.ssh"
keys_file="$ssh_dir/authorized_keys"

# Fetch first: -f makes a failed request an error instead of appending GitHub's error page.
keys=$(curl -fsS https://github.com/llbbl.keys)
[ -n "$keys" ] || { echo "no keys fetched" >&2; exit 1; }

mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"
touch "$keys_file"
# Without this, the first appended key would join an unterminated last line.
if [ -s "$keys_file" ] && [ -n "$(tail -c 1 "$keys_file")" ]; then
    echo >>"$keys_file"
fi

added=0
while IFS= read -r key; do
    [ -n "$key" ] || continue
    if ! grep -qxF "$key" "$keys_file"; then
        printf '%s\n' "$key" >>"$keys_file"
        added=$((added + 1))
    fi
done <<<"$keys"

chmod 600 "$keys_file"
echo "added $added key(s)"
