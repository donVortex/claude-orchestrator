# Shared assertions for the bash test suite. Source this from each tests/test_*.sh file.
# Bash 3.2 compatible; no external tools beyond coreutils.

_failed=0
_tmp_root=$(mktemp -d)
trap 'rm -rf "$_tmp_root"' EXIT

fail() {
  echo "FAIL: $1"
  _failed=1
}

assert_eq() {
  [ "$1" = "$2" ] || fail "$3 (expected [$1], got [$2])"
}

assert_contains() {
  case "$1" in
    *"$2"*) ;;
    *) fail "$3 (missing [$2])" ;;
  esac
}

assert_not_contains() {
  case "$1" in
    *"$2"*) fail "$3 (unexpected [$2])" ;;
  esac
}

assert_file() {
  [ -e "$1" ] || fail "$2 (no file $1)"
}

# Echoes a fresh empty directory; everything is removed when the test file exits.
make_tmp() {
  mktemp -d "$_tmp_root/t.XXXXXX"
}

finish() {
  exit "$_failed"
}
