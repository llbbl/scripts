#!/usr/bin/env bash
# Cut a deliberate major release past the "No major-version tags" ruleset:
# disable it, push the tag, then re-enable it blocking the next major up.
# Needs a terminal, so an agent running as you can't drive it.
set -euo pipefail

die() { echo "major-release: $*" >&2; exit 1; }

[[ -t 0 && -t 1 ]] || die "run this by hand from a terminal"
# ponytail: majors 1-8 only; v9 needs a two-digit next pattern.
[[ $# -ge 1 && $# -le 2 && $1 =~ ^[1-8]$ ]] || { echo "usage: $0 MAJOR [REF]   e.g. $0 1 origin/main" >&2; exit 2; }

major=$1
ref=${2:-origin/main}
tag="v$major.0.0"
next=$((major + 1))

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
id=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "No major-version tags") | .id')
[[ -n $id ]] || die "no \"No major-version tags\" ruleset in $repo"

git fetch --quiet --tags origin
commit=$(git rev-parse --verify "$ref^{commit}")
! git rev-parse -q --verify "refs/tags/$tag" >/dev/null || die "$tag already exists"

echo "Tag $(git log -1 --format='%h %s' "$commit") as $tag in $repo."
echo "The release policy on that commit must already accept $tag, or the release job will refuse it."
read -rp "Type $tag to continue: " answer </dev/tty
[[ $answer == "$tag" ]] || die "aborted"

# Runs on any exit, so a failed push never leaves tags unprotected.
trap 'gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement=active >/dev/null && echo "Tag ruleset is active."' EXIT
gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement=disabled >/dev/null

git tag -a "$tag" -m "$tag" "$commit"
git push origin "$tag"

# Block majors above this one, with or without the v. [1-9][0-9]* covers v10 and up.
gh api -X PUT "repos/$repo/rulesets/$id" --input - >/dev/null <<EOF
{"enforcement": "active", "conditions": {"ref_name": {"exclude": [], "include": [
  "refs/tags/v[$next-9]*", "refs/tags/v[1-9][0-9]*", "refs/tags/[$next-9]*", "refs/tags/[1-9][0-9]*"]}}}
EOF
echo "Pushed $tag. The ruleset now blocks v$next and above."
