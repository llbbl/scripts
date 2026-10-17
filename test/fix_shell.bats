load helpers

setup() {
  setup_stubs
  export HOME="$STUB_DIR/home"
  mkdir -p "$HOME"
  stub curl
  stub sh
}

teardown() { teardown_stubs; }

@test "fetches oh-my-zsh from raw.githubusercontent.com with curl -f" {
  run_script fix_shell.sh
  [ "$status" -eq 0 ]
  grep -q "^curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh$" "$CALLS"
}

@test "installs pathogen into ~/.vim/autoload" {
  run_script fix_shell.sh
  [ -d "$HOME/.vim/bundle" ]
  grep -q "pathogen.vim https://tpo.pe/pathogen.vim$" "$CALLS"
}

@test "stops when the oh-my-zsh download fails" {
  stub curl 'exit 22'
  run_script fix_shell.sh
  [ "$status" -ne 0 ]
  [ ! -d "$HOME/.vim" ]
}
