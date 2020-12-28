This folder contains helper scripts for git hooks.

### `update`
Updates the `main` and current branch by rebasing your commits on top of changes from the official casa repo  
This script assumes no commits were made directly to main  
Usage: `update <remote name>`  
 + `<remote name>` is the name of the remote pointing to the official casa repo

### `lint`  
Lints files on the current branch  
Usage: `lint <diff policy>`  
 + `<diff policy>`(optional) can be one of the the following
   - `--staged` lints if the files staged for commit contain lintable files
   - `--unpushed` lints files changed by commits not yet pushed to origin if they are lintable
   - `--all` (default) lints all files in the repo  
   
## Example Hook(pre-push)
    #!/bin/sh
  
    ./bin/git_hooks/update actual_casa
    ./bin/git_hooks/lint --unpushed
