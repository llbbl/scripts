load helpers

setup() {
  setup_stubs
  export HOME="$STUB_DIR/home"
  mkdir -p "$HOME"
  printf '%s\n' "export KEEP=1" >"$HOME/.zshrc"
}

teardown() { teardown_stubs; }

@test "appends one alias block and backs up .zshrc" {
  run_script macos_shell_aliases.sh
  [ "$status" -eq 0 ]
  grep -qx "export KEEP=1" "$HOME/.zshrc"
  grep -q '^alias tf="terraform"$' "$HOME/.zshrc"
  [ "$(grep -c '^# ### ALIASES ###$' "$HOME/.zshrc")" = 2 ]
  diff <(printf '%s\n' "export KEEP=1") "$HOME/.zshrc.bak"
}

@test "running again replaces the block instead of adding another" {
  run_script macos_shell_aliases.sh
  run_script macos_shell_aliases.sh
  [ "$status" -eq 0 ]
  [ "$(grep -c '^# ### ALIASES ###$' "$HOME/.zshrc")" = 2 ]
  grep -qx "export KEEP=1" "$HOME/.zshrc"
  [ ! -e "$HOME/.zshrc.tmp" ]
}

@test "does nothing without a .zshrc" {
  rm "$HOME/.zshrc"
  run_script macos_shell_aliases.sh
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.zshrc" ]
}
