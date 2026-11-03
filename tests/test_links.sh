#!/usr/bin/env bash
# Every relative Markdown link in skills/ resolves to an existing file.
. "$(dirname "$0")/lib.sh"

root=${1:-skills}

for md in $(find "$root" -name '*.md' 2>/dev/null); do
  dir=$(dirname "$md")
  for target in $(grep -o '](\([^)#]*\)' "$md" | sed 's/^](//'); do
    case "$target" in
      http://*|https://*|mailto:*|"") continue ;;
    esac
    [ -e "$dir/$target" ] || fail "$md links to missing $target"
  done
done

finish
