#!/bin/bash
set -euo pipefail

# check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed"
    exit 1
fi

# check if input provided
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <file.docx>"
    exit 1
fi

input="$1"

# check if file exists
if [ ! -f "$input" ]; then
    echo "Error: file not found: $input"
    exit 1
fi

# get filename from input
filename=$(basename -s .docx "$input")

# convert word to markdown
pandoc -f docx -t markdown "$input" -o "$filename.md"
echo "Created: $filename.md"

