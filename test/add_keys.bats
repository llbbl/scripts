load helpers
bats_require_minimum_version 1.5.0

KEY_A="ssh-ed25519 AAAAkeyA"
KEY_B="ssh-ed25519 AAAAkeyB"

setup() {
  setup_stubs
  export HOME="$STUB_DIR/home"
  mkdir -p "$HOME"
  export KEYS="$KEY_A
$KEY_B"
  # Mimics curl -f: on a failed fetch, print nothing and exit 22.
  stub curl 'if [[ -n ${FETCH_FAILS:-} ]]; then
  [[ " $* " == *" -f"* ]] && exit 22
  echo "Not Found"; exit 0
fi
printf "%s\n" "$KEYS"'
}

teardown() { teardown_stubs; }

perm() { stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1"; }

@test "creates authorized_keys with locked-down permissions" {
  run_script add_keys.sh
  [ "$status" -eq 0 ]
  diff <(printf '%s\n' "$KEY_A" "$KEY_B") "$HOME/.ssh/authorized_keys"
  [ "$(perm "$HOME/.ssh")" = 700 ]
  [ "$(perm "$HOME/.ssh/authorized_keys")" = 600 ]
}

@test "appends only the keys that are missing" {
  mkdir -p "$HOME/.ssh"
  printf '%s\n' "ssh-rsa AAAAother" "$KEY_A" >"$HOME/.ssh/authorized_keys"
  run_script add_keys.sh
  [ "$status" -eq 0 ]
  diff <(printf '%s\n' "ssh-rsa AAAAother" "$KEY_A" "$KEY_B") "$HOME/.ssh/authorized_keys"
}

@test "running twice changes nothing" {
  run_script add_keys.sh
  run_script add_keys.sh
  [ "$(wc -l <"$HOME/.ssh/authorized_keys" | tr -d ' ')" = 2 ]
}

@test "a file without a trailing newline keeps its last key intact" {
  mkdir -p "$HOME/.ssh"
  printf '%s' "ssh-rsa AAAAother" >"$HOME/.ssh/authorized_keys"
  run_script add_keys.sh
  grep -qx "ssh-rsa AAAAother" "$HOME/.ssh/authorized_keys"
  grep -qx "$KEY_A" "$HOME/.ssh/authorized_keys"
}

@test "a failed fetch fails and leaves authorized_keys alone" {
  mkdir -p "$HOME/.ssh"
  printf '%s\n' "ssh-rsa AAAAother" >"$HOME/.ssh/authorized_keys"
  FETCH_FAILS=1 run_script add_keys.sh
  [ "$status" -ne 0 ]
  diff <(printf '%s\n' "ssh-rsa AAAAother") "$HOME/.ssh/authorized_keys"
}
