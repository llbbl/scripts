#!/usr/bin/env bash
set -euo pipefail

# Download before running, so a failed fetch stops here instead of running an empty script.
installer=$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)

# install oh-my-zsh (handles shell switch automatically)
sh -c "$installer"

# install vim pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
