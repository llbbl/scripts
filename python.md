# reinstalling common pythong packages

## everytime there is a new major version of python {3.9 -> 3.10} installed we need to reinstall the packages


add more packages with ```pip install --user <package>```

generate a new requirements.txt file with
```bash
pip freeze > requirements.txt
```

get the file
```bash
curl -O https://raw.githubusercontent.com/llbbl/scripts/main/requirements.txt
```

reinstall
```bash
/opt/homebrew/bin/pip3 install -r requirements.txt
```
