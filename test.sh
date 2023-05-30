#!/bin/sh

SHGEN_DIR="${SHGEN_DIR:-$(cd -P "$(dirname "$0")" && printf '%s' "$(pwd -P)")}"

if ! shfmt -i 2 -ci -d "${SHGEN_DIR}"/*.sh; then
  printf 'style check failed'
  exit 1
fi

if ! shellcheck "${SHGEN_DIR}"/*.sh; then
  printf 'shell check failed'
  exit 1
fi

shells='ash bash dash ksh mksh pdksh sh zsh'
tests=$(find "${SHGEN_DIR}" -type f -maxdepth 1 -name "*_test.sh")

for shell in ${shells}; do
  printf '\n##############################\n# %s\n' "${shell}"
  if shell_bin=$(command -v "$shell"); then
    printf '# using %s\n' "${shell_bin}"
  else
    printf '# %s not found, skipping...\n' "${shell}"
    continue
  fi
  for t in ${tests}; do
    (exec ${shell_bin} "${t}" 2>&1)
  done
done
