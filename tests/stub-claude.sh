#!/usr/bin/env bash
# Test stand-in for the claude CLI: logs its working directory, arguments and stdin, prints a fake JSON result.
{
  echo "PWD=$(pwd)"
  echo "GIT_BASH_PATH=${CLAUDE_CODE_GIT_BASH_PATH:-}"
  echo "ORCH_ROLE=${ORCH_ROLE:-}"
  for a in "$@"; do echo "ARG=$a"; done
  echo "STDIN=$(cat)"
} >> "$STUB_LOG"
echo '{"session_id":"s-1","result":"ok"}'
