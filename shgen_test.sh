#!/bin/sh
# shellcheck disable=SC2030,SC2031,SC2317

SHGEN_DIR="${SHGEN_DIR:-$(cd -P "$(dirname "$0")" && printf '%s' "$(pwd -P)")}"

if [ -n "${ZSH_VERSION:-}" ]; then
  setopt shwordsplit
  export SHUNIT_PARENT="$0"
fi

test_shgen_render__no_such_template() (
  ret=$(shgen_render none.sh.esh 2>&1)
  assertEquals 10 $?
  assertEquals "esh: can't read ${SHGEN_DIR}/templates/none.sh.esh: not a file or not readable" "$ret"
)

test_shgen_render__unbound() (
  ret=$(shgen_render dummy.sh.esh 2>&1)
  assertNotEquals 0 $?
)

test_shgen_render() (
  SHGEN_APP_NAME='Foo'
  export SHGEN_APP_NAME
  ret=$(shgen_render dummy.sh.esh 2>&1)
  assertEquals 0 $?
  assertEquals "#!/bin/sh
# Foo" "$ret"
)

test_shgen_user_input() (
  _shgen_user_input 'Foo_Bar' >/dev/null 2>&1
  assertEquals 'Foo_Bar' "$SHGEN_APP_NAME"
  assertEquals 'FOO_BAR' "$SHGEN_APP_UPCASE"
  assertEquals 'foo_bar' "$SHGEN_APP_DOWNCASE"
)

test_shgen_user_input__strips_nonalpha() (
  _shgen_user_input '123heLLo_w0rld-v1.3.4' >/dev/null 2>&1
  assertEquals 'heLLo_wrldv' "$SHGEN_APP_NAME"
  assertEquals 'HELLO_WRLDV' "$SHGEN_APP_UPCASE"
  assertEquals 'hello_wrldv' "$SHGEN_APP_DOWNCASE"
)

test_shgen_create_dir() (
  mkdir() {
    return 0
  }
  ret=$(_shgen_create_dir 'somedir')
  assertEquals 0 $?
)

test_shgen_create_dir_exists() (
  _test() {
    return 0
  }
  mkdir() {
    fail 'expected mkdir invocation'
  }
  ret=$(_shgen_create_dir 'somedir' 2>&1)
  assertEquals 1 $?
  assertEquals "shgen: error: file exists: somedir" "$ret"
)

test_shgen_create_mkdir_fails() (
  _test() {
    return 1
  }
  mkdir() {
    return 1
  }
  ret=$(_shgen_create_dir 'somedir' 2>&1)
  assertEquals 1 $?
  assertEquals "shgen: error: could not mkdir: somedir" "$ret"
)

oneTimeSetUp() {
  . "${SHGEN_DIR}/shgen_lib.sh"
}

# shellcheck disable=all
. "$(command -v shunit2)"
