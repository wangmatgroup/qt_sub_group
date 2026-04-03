# qt_sub_group
Share input, output, and post-processing codes

### Prepare for sharing files
- **GitHub**: Generate a Personal Access Token (PAT)
Settings > Developer Settings > Personal Access Tokens > Tokens (classic) > Generate new token (classic) : Select scopes , check repo > Generate token

- **TACC** or **local**:

- 0. `git init`
     
- 1. Create a directory with file copies (`*.abi *abo* *log* *.nc *.cif *.ipynb`) to upload to GitHub  
  *It should be separate from your working directory*  
ex) `find . -name '*abi*' -name '*abo*' -name '*log*' -exec cp --parents \{\} **path/to/copies** \;`   
or
ex) `rsync -av \
  --include='*/' \
  --include='*abi*' \
  --include='*abo*' \
  --include='*log*' \
  --exclude='*' \
  **working/directory** \
  **path/to/copies**`

- 2. Set a remote at the directory(*NOT the working directory*) for uploading files   
`git remote add wangmat_qt https://github.com/wangmatgroup/qt_sub_group.git`

### Share files
1. Prepare the contents of the next commit   
`git add -v .`

2. `git branch -M **your_branch_name**`

3. `git commit -m "."`

3. `git pull --rebase wangmat_qt **your_branch_name**`

4. `git push -u wangmat_qt **your_branch_name**`

5. When updating files,  
`rsync -av \
  --include='*/' \
  --include='*abi*' \
  --include='*abo*' \
  --include='*log*' \
  --exclude='*' \
  **working/directory** \
  **path/to/copies**`
