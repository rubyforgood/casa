This folder contains helper scripts for Git hooks.

To create a hook, make a file inside the directory `.git/hooks/` with the name of the hook you want to set up. Do not use a file extension.
For example, if you want to set up a pre-commit hook, the file should be called `pre-commit`, or if you want a pre-push hook, it should be called `pre-push`.

Once you've created that file, put the appropriate she-bang on the first line:
```bash
#!/bin/sh
```
followed by the script you want to run and any arguments or flags for that script.

See [Example Hooks](#example-hooks) below for how you might want to set these up.
You can read more about Git hooks [here](https://git-scm.com/docs/githooks).

## Hook Scripts

### `lint`  
Lints files on the current branch  
Usage: `./lint <diff policy>`  
 + `<diff policy>`(optional) can be one of the the following
   - `--staged` lints the files staged for commit
   - `--unpushed` lints files changed by commits not yet pushed to origin
   - `--all` (default) lints all files in the repo  

### `migrate-all`  
Runs all migrations if any are found to be down  
Usage: `./migrate-all`  

### `update-dependences`  
Installs dependencies if any are missing  
Usage: `./update-dependencies`  
  
### `update-branch`
Updates the `main` and current branch by rebasing your commits on top of changes from the official casa repo  
This script assumes no commits were made directly to main  
Usage: `./update-branch <remote name>`  
 + `<remote name>` is the name of the remote pointing to the official casa repo
   
## Example Hooks
### pre-push
    #!/bin/sh
  
    ./bin/git_hooks/update-branch actual_casa
    ./bin/git_hooks/lint --unpushed
### post-merge, pre-push  
    #!/bin/sh

    ./bin/git_hooks/update-dependencies
    # migrate-all has to come after update-dependencies because it relies on bundle
    ./bin/git_hooks/migrate-all
