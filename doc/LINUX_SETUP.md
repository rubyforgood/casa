# Setting Up the Application on Linux

This document will provide information about getting the application up and running on Linux, 
on either a physical system or a Vagrant virtual machine. You may want to do this for the following reasons:

* to do software development
* to run the server
* to test the software


## Using a Vagrant Virtual Machine (VM)

If you will not be using a Vagrant VM, feel free to skip this section.

#### Installing Virtual Box and Vagrant

Install [Virtual Box](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) if necessary:

```
sudo apt install virtualbox vagrant
```

#### Initialize the Vagrant VM Control Directory

Create a new directory for the Vagrant VM, `cd` into it, then generate the Vagrantfile config file:
 
```
vagrant init bento/ubuntu-20.04
```

#### Accessing the VM from the Host OS

To access a server running on the Vagrant VM from a browser on the host machine, 
you will need to assign the VM an IP address in the `Vagrantfile`.
Edit that file, uncomment out the following line, and change the IP address to whatever address you want:

```
config.vm.network "private_network", ip: "192.168.33.10"
```

You may want to look at the other settings in the config file as well, to see if they may also need modification.


#### Start the VM and SSH Into It

```
vagrant up
vagrant ssh
```

Skip the rest of this section for now and do the general Linux installation. Be sure `vagrant ssh`
has brought you to your VM's prompt though, because otherwise you will be modifying 
your host operating system and not the VM!

#### Your SSH Keys

If you want to create new SSH keys, go to the general Linux instructions below; if you would like to save some
time and effort and use your host OS' keys, you can do that using the commands below. Note that you must be in
your host OS and not inside the Vagrant VM to do this:

```
vagrant plugin install vagrant-scp
vagrant scp ~/.ssh/id_rsa     :~/.ssh
vagrant scp ~/.ssh/id_rsa.pub :~/.ssh
```

#### Running the Rails Server to Accept Hosts Other than the VM

When you eventually start the rails server, add the `-b 0.0.0.0` option to allow access from hosts other than the VM:

`rails s -b 0.0.0.0`

Assuming the use of the 192.168.33.10 address specified above,
you will be able to access the running Rails server from the guest OS as `192.168.33.10:3000`.


#### Editing Files on the VM

To edit files on the Vagrant VM, you can use `vim`, which will already be installed. However, it's even
easier to set up a synchronized directory tree on both the host and guest OS so that any changes made
in one will be updated on the other. Simply add a line to the `Vagrantfile` like this one:

```
  config.vm.synced_folder "/home/kbennett/work/casa/", "/home/vagrant/casa"
```

...where the first directory spec is the host machine's project root and the second is the Vagrant VM project root.

Another approach is to use an editor on your host OS that is capable of editing files over SSH.
VS Code does this nicely, and you can start looking into this 
[here](https://code.visualstudio.com/docs/remote/ssh-tutorial). The IP address will be the one specified
in the Vagrant file, and the user id and password are both `vagrant`.

## Linux Development Environment Installation

The commands below can be run all at once by copying and pasting them all into a file and running the file as a script
(e.g. `bash -x script_name`).
 
If you copy and paste directly from this page to your command line, we recommend you do so one section (or even one line) at a time.

The commands below include a section for installing [rvm](https://rvm.io/),
but feel free to substitute your own favorite Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv).

```
# Install packages available from the main Linux repos & upgrade the Vagrant image if necessary
# 
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git git-gui htop hub libpq-dev net-tools nodejs npm openssh-server postgresql-12 vim zsh
```

```
# Install NVM and Node JS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
. ./.bashrc
nvm install 13.7.0
```

```
# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn
```

```
# Install RVM (Part 1)
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash
. ./.bashrc
rvm get head
rvm install 3.0.1
rvm alias create ruby 3.0.1
rvm alias create default ruby-3.0.1
```

```# Download the Chrome browser (for RSpec testing):
sudo curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get -y update
sudo apt-get -y install google-chrome-stable
```

```
# Add user to Postgres:
sudo -u postgres psql -c "create user vagrant with createdb"
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
