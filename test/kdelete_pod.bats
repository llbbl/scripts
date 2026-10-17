load helpers
bats_require_minimum_version 1.5.0

setup() {
  setup_stubs
  pods "default api-123" "prod api"
}

# pods "NS NAME"...: what `kubectl get pods --all-namespaces` lists.
pods() {
  printf '%s 1/1 Running 0 1d\n' "$@" >"$STUB_DIR/pods"
  stub kubectl '[[ $1 == get ]] || exit 0
[[ " $* " == *" --no-headers "* ]] || echo "NAMESPACE NAME READY STATUS RESTARTS AGE"
cat "'"$STUB_DIR"'/pods"'
}

teardown() { teardown_stubs; }

@test "no argument prints usage and fails" {
  run_script kdelete_pod.sh
  [ "$status" -eq 1 ]
  [[ $output == *Usage* ]]
}

@test "matches the exact pod name, not a substring" {
  run_script kdelete_pod.sh api
  [ "$status" -eq 0 ]
  grep -qx "kubectl delete pod api --namespace prod --grace-period=0 --force" "$CALLS"
}

@test "a partial name is not found" {
  run_script kdelete_pod.sh ap
  [ "$status" -eq 1 ]
  [[ $output == *"not found"* ]]
  run ! grep -q "kubectl delete" "$CALLS"
}

@test "refuses a name that exists in several namespaces" {
  pods "default api" "prod api"
  run_script kdelete_pod.sh api
  [ "$status" -eq 1 ]
  [[ $output == *default* && $output == *prod* ]]
  run ! grep -q "kubectl delete" "$CALLS"
}
