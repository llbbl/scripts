#!/bin/bash


# find all files in current directory
find . -type f -print0 | while IFS= read -r -d $'\0' line; do

    base_url="https://raw.githubusercontent.com/llbbl/scripts/main/util/"

    # remove "./" from start of filename
    _line=$(echo $line | sed 's/\.\///g')

    # remove any file extension from line
    # no_ext=$(echo $_line | sed 's/\..*//g')

    echo "curl -sO $base_url$_line && chmod +x $line"

done