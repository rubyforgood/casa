# Linux Development Environment Installation

The commands below can be run all at once by copying and pasting them all into a file and running the file as a script
(e.g. `bash -x script_name`).

If you copy and paste directly from this page to your command line, we recommend you do so one section (or even one line) at a time.

The commands below include a section for installing [rvm](https://rvm.io/),
but feel free to substitute your own favorite Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv).

```
# Install Linux Packages
sudo apt update                    # Check internet for updates
sudo apt upgrade -y                # Install updates
sudo apt install -y curl           # A command to help fetching and sending data to urls
sudo apt install -y git            # In case you don't have it already
sudo apt install -y libvips42      # Render images for your local web server
sudo apt install -y libpq-dev      # Helps compile C programs to be able to communicate with postgres
```  
  
```
# Install Postgres
#   Add the postgres repo
#     Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

#     Add the repo key to your keyring:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /usr/share/keyrings/postgres-archive-keyring.gpg

#     Open /etc/apt/sources.list.d/pgdg.list with super user permissions
#     Paste "[signed-by=/usr/share/keyrings/postgres-archive-keyring.gpg]" between "deb" and "http://apt.postgresql..."
#       Example: deb [signed-by=/usr/share/keyrings/postgres-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main
#     Save the file

#     Update the package lists:
sudo apt update

#   Install Postgres 12
sudo apt install -y postgresql-12

#   Add user to Postgres:
sudo -u postgres psql -c "CREATE USER $USER WITH CREATEDB"

# See https://www.postgresql.org/download/linux/ubuntu/ for more details
```

```
# Install NVM and Node JS
#   you can use curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
#   or wget
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

#   Restart your terminal

# List all available LTS versions
nvm ls-remote | grep -i 'Latest LTS'

# Install an LTS version
nvm install lts/gallium # Latest might not be gallium
# Update npm
npm i -g npm@latest
```

```
# Install Yarn
npm i -g yarn
```

```
# Install and configure rbenv
sudo apt install rbenv
rbenv init
#   Restart your terminal

#   fetch extended list of ruby versions
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

rbenv install 3.1.0
```

If you would like RVM instead of rbenv
```
# Install RVM (Part 1)
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash
. ./.bashrc
rvm get head
rvm install 3.1.0
rvm alias create ruby 3.1.0
rvm alias create default ruby-3.1.0
```

```# Download the Chrome browser (for RSpec testing):
sudo curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get -y update
sudo apt-get -y install google-chrome-stable
```

## Connecting to Github via ssh  
Connecting to Gihub via ssh prevents being required to login very often when using git commands. 

### Creating an SSH Key Pair
 - Open Terminal.
 - Paste the text below, substituting in your GitHub email address.  
`ssh-keygen -t ed25519 -C "your_email@example.com"`
 - For all prompts simply press enter to set default values.

#### Adding your SSH key to the ssh-agent
 - Run `eval "$(ssh-agent -s)"` in your terminal to start the ssh-agent in the background. It will use very few resources.
 - Run `ssh-add ~/.ssh/id_ed25519` to add your private key to the ssh agent.

See [github's article](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for more details/updates.

### Add your ssh key to your github account.  
[See github's guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

### Test Your ssh Connection
 - Run `ssh -T git@github.com`
 - If you see `Are you sure you want to continue connecting (yes/no)?`, enter `yes`
 - If you see `Hi username! You've successfully authenticated, but GitHub does not provide shell access.`, the connection is set up correctly.

#### Final Steps

`cd` to the directory under which you would like to install the CASA software
(if the home directory, and you are not already there, `cd` alone will work). Then:

```
git clone git@github.com:rubyforgood/casa.git
```

If you see this, respond with yes:

```
The authenticity of host 'github.com (140.82.112.3)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

Now to set up the gems, JavaScript libraries, and data base:

```
cd casa
bin/rails db:setup
bin/update
yarn
```

(`bin/update` is a very useful script that should be run after each `git pull` and can be used whenever you want to make sure your setup is up to date with respect to code and configuration changes.)

Run the tests and/or the server!:

```
bin/rails spec               # run the tests

bin/rails server             # run the server only for localhost clients
# or
bin/rails server -b 0.0.0.0  # run the server for any network-connected clients
```

If the tests all pass and you can access the running Rails server from the host OS,
then your installation is successful!

A `bin/login` script is provided to simplify the launching and logging in to the application. It cannot be used on the Vagrant VM since the Vagrant VM has no graphical environment.
