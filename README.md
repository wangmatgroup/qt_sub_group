# qt_sub_group
Share input, output, and post-processing codes

1. Generate a Personal Access Token (PAT)
Settings > Developer Settings > Personal Access Tokens > Tokens (classic) > Generate new token (classic) : Select scopes , check repo > Generate token

2. Set a remote at the working directory of TACC 
`git remote add wangmat_qt https://github.com/wangmatgroup/qt_sub_group.git`

3. Prepare the contents of the next commit 
`git add -v *.abi *.abo *.log *_GSR.nc`

4. git branch -M **your_branch_name**
