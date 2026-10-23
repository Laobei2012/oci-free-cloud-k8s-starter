#!/usr/bin/env bash
# Tests changed-stacks.sh. Run it from the root of the repository.
set -euo pipefail

script=$PWD/.github/scripts/changed-stacks.sh
fails=0

expect() {
  local name=$1 want=$2 got=$3
  if [ "$got" = "$want" ]; then
    echo "ok   $name"
  else
    echo "FAIL $name: want $want, got $got"
    fails=$((fails + 1))
  fi
}

expect "one stack" '["accounts/a"]' \
  "$(printf '%s\n' terraform/accounts/a/main.tf | "$script")"
expect "two stacks in apply order" '["accounts/b","clusters/oci"]' \
  "$(printf '%s\n' terraform/clusters/oci/x.tfvars terraform/accounts/b/main.tf | "$script")"
expect "no Terraform file" '[]' \
  "$(printf '%s\n' README.md terraform/accounts/a/backend.hcl.example | "$script")"
expect "all stacks" '["accounts/a","accounts/b","clusters/oci"]' \
  "$("$script" --all < /dev/null)"

# a copy without account B
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/terraform/accounts" "$tmp/terraform/clusters"
cp -R terraform/accounts/a "$tmp/terraform/accounts/a"
cp -R terraform/clusters/oci "$tmp/terraform/clusters/oci"
expect "all stacks without account B" '["accounts/a","clusters/oci"]' \
  "$(cd "$tmp" && "$script" --all < /dev/null)"
expect "deleted account B folder" '[]' \
  "$(cd "$tmp" && printf '%s\n' terraform/accounts/b/main.tf | "$script")"

[ "$fails" -eq 0 ]
