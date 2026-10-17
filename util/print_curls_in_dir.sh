#!/usr/bin/env bash
set -euo pipefail

# find the scripts in the current directory
find . -type f -name '*.sh' -print0 | while IFS= read -r -d $'\0' line; do
    base_url="https://raw.githubusercontent.com/llbbl/scripts/main/util/"

    # remove "./" from start of filename
    _line=${line#./}

    echo "curl -sO $base_url$_line && chmod +x $_line"
done