#!/usr/bin/env bash
# README: how to use the plugin on a project that already exists.
. "$(dirname "$0")/lib.sh"

readme=$(cat README.md 2>/dev/null)

assert_contains "$readme" "### On an existing project" "README: existing-project section"
assert_contains "$readme" "**What it needs from your project:**" "README: what it needs"
assert_contains "$readme" "**What it adds to your repo:**" "README: what it adds"
assert_contains "$readme" "**What stays out of git:**" "README: what stays out of git"
assert_contains "$readme" "**What it never touches:**" "README: what it never touches"
assert_contains "$readme" "**Working in a team:**" "README: teams"
assert_contains "$readme" "**Removing it:**" "README: removal"
assert_contains "$readme" ".git/info/exclude" "README: .orchestration excluded without touching .gitignore"
assert_contains "$readme" "a new session there continues it on its own" "README: resume without a command in projects with knowledge"

finish
