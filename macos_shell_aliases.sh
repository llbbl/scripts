
# append to end of file with awk
function append_to_file_awk() {
    echo "$1" | awk '{print $0 >> "'$2'"}'
}
# remove everything 
function remove_aliases() {
    sed -i '' '/# ### ALIASES ###/,/# ### ALIASES ###/d' "$1"
}

# get current date in string
d=$(date +%Y-%m-%d)

ALIASES="# ### ALIASES ###
# ### updated: $d ###

alias recent=\"find . -type d -mtime -30 -maxdepth 1 -mindepth 1\"
alias recent.day=\"find . -type d -mtime -1 -maxdepth 1 -mindepth 1\"
alias recent.week=\"find . -type d -mtime -7 -maxdepth 1 -mindepth 1\"

# add string to the end of the file
alias append=\"echo '\$1' >>\"

# javascript aliases
#
# fix next cli
alias next=\"npx next\"
alias npm-list-globals=\"npm list -g --depth 0\"

# write out .nvmrc file
alias nvmrc=\"node -v > .nvmrc\"

# python 3
alias python='/opt/homebrew/bin/python3'
alias pip='/opt/homebrew/bin/pip3'

# ### ALIASES ###
"


# if file .zshrc exists append to end of the file
if [ -f ~/.zshrc ]; then
    remove_aliases "$HOME/.zshrc"
    append_to_file_awk "$ALIASES" "$HOME/.zshrc"

fi






