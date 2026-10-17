load helpers

setup() {
  setup_stubs
  cd "$STUB_DIR" || exit 1
  touch convert.sh notes.txt .DS_Store
}

teardown() { teardown_stubs; }

@test "prints a curl line for each script and nothing else" {
  run_script util/print_curls_in_dir.sh
  [ "$status" -eq 0 ]
  [ "$output" = "curl -sO https://raw.githubusercontent.com/llbbl/scripts/main/util/convert.sh && chmod +x convert.sh" ]
}
