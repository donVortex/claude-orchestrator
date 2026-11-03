#!/usr/bin/env bash
# Test stand-in for the claude CLI: logs its working directory and arguments, prints a fake JSON result.
{
  echo "PWD=$(pwd)"
  for a in "$@"; do echo "ARG=$a"; done
} >> "$STUB_LOG"
echo '{"session_id":"s-1","result":"ok"}'
