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
sudo apt install -y postgresql-12  # Postgres; our database management system
sudo apt install -y libvips42      # Render images for your local web server
sudo apt install -y libpq-dev      # Helps compile C programs to be able to communicate with postgres
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
# OR
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn
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

```
# Add user to Postgres:
sudo -u postgres psql -c "CREATE USER $USER WITH CREATEDB"
# If you are using a VM
sudo -u postgres psql -c "CREATE USER vagrant WITH CREATEDB"
```

#### Creating an SSH Key Pair

(If you are using a Vagrant VM and want to use your host OS key pair, go back up to the Vagrant
instructions to see how to do that.)

If you do not already have an SSH key pair, you can create it with the defaults with this
(see [this article](https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt#:~:text=If%20you%20don't%20want,flag%20%2Df%20to%20the%20command.&text=This%20way%20user%20will%20not,file(s)%20already%20exist.&text=leave%20out%20the%20%3E%2Fdev%2F,you%20want%20to%20print%20output.)
for more information about this command):

`ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null`

#### Adding Your Key to Your Github Account

Skip this step if your public SSH key is already registered with your Github account.

* Go to https://github.com/login and log in.
* Click the circle, probably containing your photo, in the upper right corner.
* Select "Settings".
* Select "SSH and GPG Keys" on the left panel.
* Click the green "New SSH Key" on the top right of the window.
* For "Title", input something descriptive of this host to you
* For "Key", paste the content of your ~/.ssh/id_rsa.pub file.
* Press the green "Add SSH Key" button to submit the new key.

#### Final Steps

(If your host is a Vagrant VM, `vagrant ssh` into it if you are not already there.)

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
# webpacker one time setup
bundle exec rails webpacker:compile
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
