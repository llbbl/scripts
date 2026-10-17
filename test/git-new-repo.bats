load helpers

setup() {
  setup_stubs
  stub git
  mkdir "$STUB_DIR/work"
  cd "$STUB_DIR/work" || exit 1
}

teardown() { teardown_stubs; }

@test "no argument prints usage and fails" {
  run_script git-new-repo.sh
  [ "$status" -eq 1 ]
  [[ $output == *Usage* ]]
}

@test "refuses an existing repository" {
  mkdir .git
  run_script git-new-repo.sh git@github.com:user/repo.git
  [ "$status" -eq 1 ]
  [[ $output == *"Already a git repository"* ]]
  [ ! -s "$CALLS" ]
}

@test "initializes, adds the remote, commits, and names the branch main" {
  run_script git-new-repo.sh git@github.com:user/repo.git
  [ "$status" -eq 0 ]
  diff <(printf '%s\n' "git init" "git remote add origin git@github.com:user/repo.git" \
    "git add ." "git commit -m Initial commit" "git branch -M main") "$CALLS"
}
