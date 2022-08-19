#!/bin/zsh


if [ ! -d "$HOME/.ssh" ]; then
    echo "create folder"
    mkdir $HOME/.ssh
fi

# "create temp keys"
curl -s https://github.com/llbbl.keys > ~/.ssh/.logan_authorized_keys

# if file exists
if [ -f $HOME/.ssh/authorized_keys ]; then
    # "file exists"

    isInFile=$(grep -c -f $HOME/.ssh/.logan_authorized_keys $HOME/.ssh/authorized_keys)

    if [ $isInFile -eq 0 ]; then
        echo "file appended"
        curl -s https://github.com/llbbl.keys >> ~/.ssh/authorized_keys
    else
        echo "keys exist"
    fi
else
# file does not exist ; 
    echo "file created"
    curl -s https://github.com/llbbl.keys > ~/.ssh/authorized_keys
fi

rm -f ~/.ssh/.logan_authorized_keys

echo "fix permissions"
chmod go-rwx ~/.ssh/authorized_keys


