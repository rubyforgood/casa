**Nix** 

If you have [Nix](https://nixos.org) installed you can use the [flake.nix](flake.nix)
configuration file located at the root of the project to build and develop within an environment
without needing to install `rvm`, `nodejs`, `yarn`, `postgresql` or other tools separately.
The environment also uses the `gemset.nix` file to automatically download and install all the gems
necessary to get the server up and running:

1. Install [Nix](https://zero-to-nix.com/concepts/nix-installer)
2. Add the following to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
```
    experimental-features = nix-command flakes
```
3. `cd` into casa
4. `nix-shell -p bundix --run "bundix -l"` to update the `gemset.nix` file
5. `nix develop` and wait for the packages to be downloaded and the environment to be built

Then you can setup the database and run the server.
This will run on Linux and macOS.