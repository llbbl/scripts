load helpers
bats_require_minimum_version 1.5.0

setup() {
  setup_stubs
  # RUNNING holds the ids `docker ps -q` returns.
  stub docker 'if [[ "$*" == "ps -q" ]]; then [[ -z ${RUNNING:-} ]] || printf "%s\n" $RUNNING; fi'
}

teardown() { teardown_stubs; }

# answer REPLY: run docker-clean.sh, typing REPLY at the prompt.
answer() {
  run bash -c 'printf "%s" "$1" | "$2" "$3/docker-clean.sh"' _ "$1" "$TEST_BASH" "$ROOT"
}

@test "anything but y aborts without changing anything" {
  answer n
  [ "$status" -eq 0 ]
  [[ $output == *Aborted* ]]
  run ! grep -qE "docker (stop|.* prune)" "$CALLS"
}

@test "stops every running container in one call" {
  export RUNNING="c1 c2"
  answer y
  [ "$status" -eq 0 ]
  grep -qx "docker stop c1 c2" "$CALLS"
  grep -qx "docker volume prune -f" "$CALLS"
}

@test "skips the stop when nothing is running" {
  answer y
  [ "$status" -eq 0 ]
  [[ $output == *"No running containers"* ]]
  run ! grep -q "docker stop" "$CALLS"
  grep -qx "docker image prune -af" "$CALLS"
}
