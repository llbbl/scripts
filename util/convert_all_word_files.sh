#!/bin/bash
set -euo pipefail

# check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed"
    exit 1
fi

# save current working directory to variable
cwd=$(pwd)

# find all .docx files in current directory
find "$cwd" -name "*.docx" -type f -print0 | while IFS= read -r -d $'\0' line; do
    # remove spaces in filename for output
    ns_filename=$(echo "$line" | sed 's/ /_/g')

    # get filename from input
    the_filename=$(basename -s .docx "$ns_filename")

    # convert word to markdown
    pandoc -f docx -t markdown "$line" -o "$the_filename.md"
    echo "Created: $the_filename.md"
done

