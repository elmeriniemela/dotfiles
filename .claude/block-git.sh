#!/usr/bin/env bash
# ~/.claude/block-git.sh
cmd=$(jq -r '.tool_input.command // ""')
if grep -qE '(^|[^[:alnum:]_])git([[:space:]]|$)' <<<"$cmd"; then
  echo "git is disabled by policy on this machine" >&2
  exit 2
fi
exit 0