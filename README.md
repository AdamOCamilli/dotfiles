# dotfiles
My dotfiles using $HOME as a git clone. To initialize on new machine, first backup and remove any conflicting (and currently untracked) rc files:
```
cd $HOME
export backup_dir="dotfiles_bak_$(date +%s)"
mkdir -p "${backup_dir}"
git ls-tree --name-only -r origin/main | grep -Fxf <(git ls-files --other --exclude-standard) | xargs -I {} sh -c 'cp -v --parents "{}" "${backup_dir}" ; rm -fv "{}"'
unset backup_dir
```

Then checkout main branch:
```
git init
git branch -m main
git remote add origin https://github.com/AdamOCamilli/dotfiles/
git fetch origin
git checkout -b main origin/main
```


