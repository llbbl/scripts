load helpers

setup() {
  setup_stubs
  export HOME="$STUB_DIR/home"
  mkdir -p "$HOME/Web"
  stub gh
  stub git
}

teardown() { teardown_stubs; }

@test "no argument prints usage and fails" {
  run_script clone-to-web.sh
  [ "$status" -eq 1 ]
  [[ $output == *Usage* ]]
}

@test "owner/repo clones with gh" {
  run_script clone-to-web.sh llbbl/scripts
  [ "$status" -eq 0 ]
  grep -qx "gh repo clone llbbl/scripts" "$CALLS"
  [[ $output == *"Cloned to: $HOME/Web/scripts"* ]]
}

@test "a URL clones with git and strips .git" {
  run_script clone-to-web.sh git@github.com:llbbl/scripts.git
  [ "$status" -eq 0 ]
  grep -qx "git clone git@github.com:llbbl/scripts.git" "$CALLS"
  [[ $output == *"Cloned to: $HOME/Web/scripts"* ]]
}
