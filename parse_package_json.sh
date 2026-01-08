#!/bin/bash

# Read the package.json file
json=$(cat package.json)

# Use jq to parse the file and construct the npm install command
command=$(echo "$json" | jq -r '
  .dependencies,
  .devDependencies
  | to_entries[]
  | "\(.key)@\(.value)"
' | xargs echo pnpm install)

# Print the command
echo "$command"
