#!/bin/sh

if [ -n "${SHGEN_VERSION:-}" ]; then
  return 0
fi
if [ -n "${ZSH_VERSION:-}" ]; then
  # shellcheck disable=SC3010
  if ! [[ -o shwordsplit ]]; then
    printf '%s\n%s\n\n' \
      'Sourcing this library from zsh requires the shwordsplit option, e.g.:' \
      'setopt shwordsplit' >&2
    return 0
  fi
fi
SHGEN_VERSION='0.0.1'

_shgen_cleanup() {
  # cleanup code goes here
  :
}

_test() {
  test "$@"
}

_shgen_usage() {
  cat <<HERE
NAME
    shgen.sh - shell script project generator

SYNOPSIS
    shgen.sh [-e] name

DESCRIPTION
    Generate a shell script project in a new directory <name>.

    The following options are available:

    -e    Executable script only; do not split into executable and library.
          Not recommended, but allows distributing as a single file.

    In project code, <name> will be stripped to include only letters
    and underscore (_) characters, e.g. "My App" would become "myapp".
HERE
}

_shgen_user_input() {
  if _test -z "$1"; then
    return 1
  fi
  SHGEN_APP_NAME=$(printf '%s' "$1" | tr -d -c '[:alpha:]_')
  SHGEN_APP_DOWNCASE=$(printf '%s' "$SHGEN_APP_NAME" | tr '[:upper:]' '[:lower:]')
  SHGEN_APP_UPCASE=$(printf '%s' "$SHGEN_APP_NAME" | tr '[:lower:]' '[:upper:]')
  export SHGEN_APP_NAME
  export SHGEN_APP_DOWNCASE
  export SHGEN_APP_UPCASE
  return 0
}

shgen_render() (
  "${SHGEN_DIR}/tools/esh" "${SHGEN_DIR}/templates/$1"
)

_shgen_create_dir() (
  if _test -e "./$1"; then
    printf "shgen: error: file exists: %s\n" "$1" >&2
    return 1
  fi
  if ! mkdir "$1"; then
    printf 'shgen: error: could not mkdir: %s' "$1" >&2
    return 1
  fi
)

shgen_main() {
  while getopts 'e' opt; do
    case "$opt" in
      e)
        # process option
        ;;
      ?)
        _shgen_usage
        exit 1
        ;;
    esac
    shift
  done
  if ! _shgen_user_input "$1"; then
    _shgen_usage
    exit 1
  fi
  if ! _shgen_create_dir "$1"; then
    exit 1
  fi
  (
    set -e
    cd "$1"

    # script
    shgen_render app.sh.esh >"${SHGEN_APP_DOWNCASE}.sh"
    chmod +x "${SHGEN_APP_DOWNCASE}.sh"

    # library
    shgen_render app_lib.sh.esh >"${SHGEN_APP_DOWNCASE}_lib.sh"

    # tests
    shgen_render app_test.sh.esh >"${SHGEN_APP_DOWNCASE}_test.sh"
    chmod +x "${SHGEN_APP_DOWNCASE}_test.sh"

    # test runner
    shgen_render test.sh.esh >test.sh
    chmod +x test.sh

    # integration test runner
    shgen_render test_it.sh.esh >test_it.sh
    chmod +x test_it.sh

    # docker files
    cp "${SHGEN_DIR}/files/Dockerfile.alpine" .
    cp "${SHGEN_DIR}/files/Dockerfile.ubuntu" .
  )
  return $?
}
