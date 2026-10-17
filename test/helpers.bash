# Shared bats setup. Stub commands go first on PATH and log their arguments to
# $CALLS, so tests never touch real systems. Set TEST_BASH to choose the bash
# that runs the scripts (CI uses /bin/bash on macOS to cover bash 3.2).

ROOT="$BATS_TEST_DIRNAME/.."
TEST_BASH=${TEST_BASH:-bash}

setup_stubs() {
  STUB_DIR=$(mktemp -d)
  mkdir "$STUB_DIR/bin"
  export CALLS="$STUB_DIR/calls.log"
  : >"$CALLS"
  export PATH="$STUB_DIR/bin:$PATH"
}

teardown_stubs() {
  rm -rf "$STUB_DIR"
}

# stub NAME [BODY]: BODY runs after the call is logged, with "$@" set.
stub() {
  printf '#!/usr/bin/env bash\necho "%s $*" >>"$CALLS"\n%s\n' "$1" "${2:-}" >"$STUB_DIR/bin/$1"
  chmod +x "$STUB_DIR/bin/$1"
}

# run_script NAME ARGS...: run a repo script under $TEST_BASH.
run_script() {
  local name=$1
  shift
  run "$TEST_BASH" "$ROOT/$name" "$@"
}
