#!/usr/bin/env bash
# Reads changed file paths on stdin, one per line, and prints the stacks that
# need a plan as a JSON list, in apply order.
# Only Terraform inputs count: *.tf, *.tfvars, the provider lock file, and the
# files/ folder that a stack reads with file() or templatefile().
# --all prints every stack, and ignores stdin.
# A stack counts only if its folder exists, so a copy without account B works.
set -euo pipefail

all=false
if [ "${1:-}" = --all ]; then all=true; else files=$(cat); fi
stacks=()
for stack in accounts/a accounts/b clusters/oci; do
  [ -d "terraform/$stack" ] || continue
  if $all || grep -qE "^terraform/$stack/(.+\.tf|.+\.tfvars|\.terraform\.lock\.hcl|files/.+)\$" <<< "$files"; then
    stacks+=("$stack")
  fi
done
# bash 3.2 on macOS treats an empty array as unset
jq -cn '$ARGS.positional' --args ${stacks[@]+"${stacks[@]}"}
