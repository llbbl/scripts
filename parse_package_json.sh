#!/usr/bin/env bash
set -euo pipefail

# Print a `pnpm add` command for package.json's dependencies, and a separate
# `pnpm add -D` for devDependencies. Missing sections are skipped.
deps() {
    jq -r --arg section "$1" '(.[$section] // {}) | to_entries[] | "\(.key)@\(.value)"' package.json | tr '\n' ' ' | sed 's/ $//'
}

[ -f package.json ] || { echo "package.json not found" >&2; exit 1; }

dependencies=$(deps dependencies)
dev_dependencies=$(deps devDependencies)

[ -z "$dependencies" ] || echo "pnpm add $dependencies"
[ -z "$dev_dependencies" ] || echo "pnpm add -D $dev_dependencies"
