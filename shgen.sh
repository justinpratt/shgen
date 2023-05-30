#!/bin/sh

SHGEN_DIR="${SHGEN_DIR:-$(cd -P "$(dirname "$0")" && printf '%s' "$(pwd -P)")}"
if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
fi

. "${SHGEN_DIR}/shgen_lib.sh"

trap '_shgen_cleanup' 1 2 3 6
shgen_main "$@"
