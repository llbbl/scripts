load helpers
bats_require_minimum_version 1.5.0

setup() {
  setup_stubs
  stub gh 'case "$*" in
  "repo view"*) echo owner/repo ;;
  "api repos/owner/repo/rulesets --jq"*) echo 42 ;;
  *--input*) cat >>"$CALLS" ;;
esac'
  stub git 'case "$1 ${2:-}" in
  "rev-parse --verify") echo abc123 ;;
  "rev-parse -q") [[ -n ${TAG_EXISTS:-} ]] ;;
  "log -1") echo "abc123 feat: something" ;;
  "push origin") [[ -z ${PUSH_FAILS:-} ]] ;;
esac'
}

teardown() { teardown_stubs; }

# run_tty ANSWER ARGS...: run major-release.sh under a pseudo-terminal, typing
# ANSWER once the script logs `git log -1`, its last call before the prompt.
# Typing earlier loses the line under BSD script; a fixed sleep was flaky on CI.
# An empty ANSWER types nothing, for runs that exit before the prompt.
run_tty() {
  local answer=$1 cmd
  shift
  cmd="$TEST_BASH $ROOT/major-release.sh $*"
  if script --version >/dev/null 2>&1; then
    run bash -c '{ [ -z "$1" ] || { for _ in $(seq 100); do grep -q "^git log -1" "$CALLS" && break; sleep 0.1; done; sleep 0.5; printf "%s\n" "$1"; sleep 1; }; } | script -qec "$2" /dev/null' _ "$answer" "$cmd"
  else
    # shellcheck disable=SC2086 # cmd is split into words on purpose
    run bash -c '{ [ -z "$1" ] || { for _ in $(seq 100); do grep -q "^git log -1" "$CALLS" && break; sleep 0.1; done; sleep 0.5; printf "%s\n" "$1"; sleep 1; }; } | script -q /dev/null $2' _ "$answer" "$cmd"
  fi
}

@test "refuses without a terminal" {
  run_script major-release.sh 1 </dev/null
  [[ $output == *"from a terminal"* ]]
  [ ! -s "$CALLS" ]
}

@test "rejects majors outside 1-8" {
  run_tty "" 9
  [[ $output == *usage* ]]
  [ ! -s "$CALLS" ]
}

@test "wrong confirmation changes nothing" {
  run_tty v2.0.0 1
  [[ $output == *aborted* ]]
  run ! grep -q -- "-X PUT" "$CALLS"
}

@test "refuses an existing tag" {
  TAG_EXISTS=1 run_tty "" 1
  [[ $output == *"already exists"* ]]
  run ! grep -q -- "-X PUT" "$CALLS"
}

@test "disables, tags, pushes, then blocks v2 and up" {
  run_tty v1.0.0 1
  disabled=$(grep -n "enforcement=disabled" "$CALLS" | cut -d: -f1)
  pushed=$(grep -n "git push origin v1.0.0" "$CALLS" | cut -d: -f1)
  blocked=$(grep -n '"refs/tags/v\[2-9\]\*"' "$CALLS" | cut -d: -f1)
  [ "$disabled" -lt "$pushed" ] && [ "$pushed" -lt "$blocked" ]
  grep -q "git tag -a v1.0.0 -m v1.0.0 abc123" "$CALLS"
  grep -q '"refs/tags/\[2-9\]\*"' "$CALLS"
  tail -1 "$CALLS" | grep -q "enforcement=active"
}

@test "failed push re-enables the ruleset" {
  PUSH_FAILS=1 run_tty v1.0.0 1
  run ! grep -q -- "--input" "$CALLS"
  tail -1 "$CALLS" | grep -q "enforcement=active"
}
