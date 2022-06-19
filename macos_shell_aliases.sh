
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

# javascript
alias next=\"npx next\"
alias npm-list-globals=\"npm list -g --depth 0\"
alias npm-check-globals=\"npm outdated -g --depth=0\"

# alias npm-upgrade-globals='echo \"upgrade individual with: npm update -g <package_name>\"'
alias npm-upgrade-globals='npm update -g'

alias npm-list-dev-dependencies=\"npm list --depth=0 --dev\"

alias npm-version=\"echo '[node version]' && nvm ls current && echo '[npm version]' && npm --version && echo '[where is npm]' && which npm\"

# check npx is installed
alias npx-check=\"npx --version\"

# write out .nvmrc file
alias nvmrc=\"node -v > .nvmrc\"

# python 3
alias python='/opt/homebrew/bin/python3'
alias pip='/opt/homebrew/bin/pip3'

# php, composer, laravel
alias php-version=\"echo '[php -v]' && php -v && echo '[where is php]' && ls -al /opt/homebrew/bin/php\"

# list composer global packages
alias composer-list-globals=\"composer global show\"

# composer global update everything
alias composer-global-update=\"composer global update\"

# composer install global packages
alias composer-global=\"composer global require\"

# composer search global packages
alias composer-search-global=\"composer-list-globals | grep\"

# composer global remove a package
alias composer-global-remove=\"composer global remove\"



# ### ALIASES ###
"


# if file .zshrc exists append to end of the file
if [ -f ~/.zshrc ]; then
    remove_aliases "$HOME/.zshrc"
    append_to_file_awk "$ALIASES" "$HOME/.zshrc"

fi






