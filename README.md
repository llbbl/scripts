# scripts

Personal bash scripts for system setup and dev workflows.

## Setup Scripts

**Add SSH keys from GitHub to authorized_keys**
```bash
curl -s https://raw.githubusercontent.com/llbbl/scripts/main/add_keys.sh | /bin/bash
```

**Install Oh My ZSH + basic VIM setup**
```bash
curl -s https://raw.githubusercontent.com/llbbl/scripts/main/fix_shell.sh | /bin/bash
```

**Add aliases to .zshrc**
```bash
curl -s https://raw.githubusercontent.com/llbbl/scripts/main/macos_shell_aliases.sh | /bin/bash
```

## Docker

**docker-clean.sh** - Full Docker cleanup (stops containers, prunes images/volumes/networks)
```bash
docker-clean.sh
```

## Git

**git-new-repo.sh** - Initialize a new repo with remote and initial commit
```bash
git-new-repo.sh git@github.com:user/repo.git
```

**clone-to-web.sh** - Clone a repo to ~/Web directory
```bash
clone-to-web.sh owner/repo              # uses gh
clone-to-web.sh git@github.com:user/repo.git  # uses git
```

## DevOps

**kdelete_pod.sh** - Delete a Kubernetes pod by name (searches all namespaces)
```bash
kdelete_pod.sh <pod-name>
```

**terraform-finder.sh** - Find and report on Terraform projects in a directory
```bash
terraform-finder.sh [search-dir]
```

## JavaScript/Node

**parse_package_json.sh** - Extract dependencies from package.json as npm install command
```bash
parse_package_json.sh
```

## Utilities (util/)

**convert_doc_md.sh** - Convert a Word doc to markdown
```bash
convert_doc_md.sh <file.docx>
```

**convert_all_word_files.sh** - Convert all .docx files in current directory to markdown

**print_curls_in_dir.sh** - Print curl commands to download files from this repo

## macOS

**brew-maintain.sh** - Homebrew maintenance (update, upgrade, cleanup, doctor)
```bash
brew-maintain.sh
```

## Analysis

**analyze_history.go** - Analyze zsh history to find frequent commands and suggest scripts
```bash
go run analyze_history.go
```

## Python CLI Tools

For global Python CLI tools, use `pipx`:

```bash
pipx install cookiecutter
pipx install molecule
pipx install autopep8
```

---

You are welcome to have a peek but this repo is intended for my use only.
