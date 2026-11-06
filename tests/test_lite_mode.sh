#!/usr/bin/env bash
# Lite mode: a user-chosen, faster and cheaper way to run a project or a run.
. "$(dirname "$0")/lib.sh"

tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
calib=$(cat skills/orchestrating/references/knowledge-templates/calibration.md 2>/dev/null)
cmd=$(cat commands/orchestrate.md 2>/dev/null)

# Switching it on
assert_contains "$tiers" "## Lite mode" "tiers: lite mode section"
assert_contains "$tiers" "the orchestrator never turns it on by itself" "tiers: only the user turns it on"
assert_contains "$tiers" '`Mode: lite` entry' "tiers: per-project switch"
assert_contains "$tiers" '"full" forces the normal mode' "tiers: full overrides"
assert_contains "$tiers" "running workers finish on their current tier" "tiers: mid-run switch spares running workers"
assert_contains "$tiers" '[event] mode: <lite|full> from T<n> on' "tiers: mid-run switch logged"
assert_contains "$cmd" "[lite]" "command hint mentions lite"
assert_contains "$ledger" 'Mode: full|lite' "ledger header records the mode"

# What changes
assert_contains "$tiers" '`deep` runs as `standard`' "lite caps deep at standard"
assert_contains "$tiers" "security, authentication, money, deleting data or migrations" "lite guardrail areas keep their tier"
assert_contains "$tiers" "one combined review" "lite: one combined review per subtask"
assert_contains "$tiers" "no bootstrap" "lite skips the bootstrap"
assert_contains "$tiers" "Escalation is unchanged" "lite keeps escalation"
assert_contains "$tiers" "Lite never skips" "lite: what stays"

# Wired into the flow
assert_contains "$orch" "references/model-tiers.md#lite-mode" "orchestrating links lite mode"
assert_contains "$orch" 'Mode: <lite|full> (<source>)' "approval gate shows the mode"
assert_contains "$orch" 'say "full" to switch' "plan says how to leave lite"
assert_contains "$brief" "- Mode: full | lite" "brief carries the mode"
assert_contains "$worker" "Mode: lite" "worker follows lite mode"
assert_contains "$worker" "one combined review" "worker: one combined review in lite"

# Learning
assert_contains "$learning" '`Mode: lite`' "learning: proposes Mode: lite"
assert_contains "$learning" '`Mode: …`' "learning: Mode prefix counts under any heading"
assert_contains "$calib" "## Mode" "calibration template has a Mode section"

# README explains the modes
readme=$(cat README.md 2>/dev/null)
assert_contains "$readme" "## Modes: full and lite" "README: modes section"
assert_contains "$readme" "/session-orchestrator:orchestrate lite: <goal>" "README: one-run switch"
assert_contains "$readme" '`Mode: lite` entry' "README: per-project switch"
assert_contains "$readme" "During a run" "README: mid-run switch"
assert_contains "$readme" "Lite never cuts the safety net" "README: what lite keeps"

# README: install and use, step by step
assert_contains "$readme" "**You need:**" "README: requirements"
assert_contains "$readme" "claude plugin install session-orchestrator@session-orchestrator --scope user" "README: install command"
assert_contains "$readme" "claude plugin update session-orchestrator@session-orchestrator" "README: manual update"
assert_contains "$readme" "claude plugin uninstall session-orchestrator@session-orchestrator" "README: uninstall"
assert_contains "$readme" "### Your first run in a project" "README: first-run walkthrough"
assert_contains "$readme" "**You merge; it never does.**" "README: user merges"
assert_contains "$readme" "### Every run after that" "README: later runs"
assert_contains "$readme" "continue the orchestration" "README: how to resume"

finish
