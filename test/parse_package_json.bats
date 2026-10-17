load helpers

setup() {
  setup_stubs
  cd "$STUB_DIR"
}

teardown() { teardown_stubs; }

@test "prints separate commands for dependencies and devDependencies" {
  echo '{"dependencies": {"a": "^1.0.0", "b": "2.0.0"}, "devDependencies": {"c": "^3.0.0"}}' >package.json
  run_script parse_package_json.sh
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm add a@^1.0.0 b@2.0.0
pnpm add -D c@^3.0.0" ]
}

@test "works without devDependencies" {
  echo '{"dependencies": {"a": "^1.0.0"}}' >package.json
  run_script parse_package_json.sh
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm add a@^1.0.0" ]
}

@test "works without dependencies" {
  echo '{"devDependencies": {"c": "^3.0.0"}}' >package.json
  run_script parse_package_json.sh
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm add -D c@^3.0.0" ]
}

@test "fails without package.json" {
  run_script parse_package_json.sh
  [ "$status" -ne 0 ]
}
