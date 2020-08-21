# Setting Up the Application on Linux

This document will provide information about getting the application up and running on Linux, 
on either a physical system, or a Vagrant virtual machine. You may want to do this for the following reasons:

* to do software development for the project
* to run the server
* to test the software


## Using a Vagrant Virutal Machine (VM)

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
you will be able to access the running Rails server from the guest os as `192.168.33.10:3000`.


#### Editing Files on the VM

To edit files on the Vagrant VM, you can use `vim`, which will already be installed. 
In addition, you can use any editor on your host OS that is capable of editing files over SSH.
You can start looking into this [here](https://code.visualstudio.com/docs/remote/ssh-tutorial).
The IP address will be the one you just specified in the Vagrantfile.

## Linux Development Environment Installation

The commands below can be run all at once, but it's safer to execute them a section at a time,
to more easily spot any errors that may occur.

```
# Install packages available from the main Linux repos & upgrade the Vagrant image if necessary
# 
sudo apt update
sudo apt upgrade
sudo apt install -y curl git git-gui htop hub libpq-dev net-tools nodejs npm openssh-server postgresql-12 vim zsh

# Install NVM and Node JS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
. ./.bashrc
nvm install 13.7.0


# Install Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn


# Install RVM (Part 1)
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash
. ./.bashrc
rvm get head
rvm install 2.7.1
rvm alias create ruby 2.7.1


# Download the Chrome browser (for RSpec testing):
sudo curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get -y update
sudo apt-get -y install google-chrome-stable


# Add user to Postgres:
sudo -u postgres psql -c "create user $(whoami) with createdb"
```

Press [Ctrl-D] to log out and log back in again in a new shell (`vagrant ssh` for Vagrant), then:

`rvm --default 2.7.1`

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

In the Vagrant VM, `cd` to the directory under which you would like to install the CASA software 
(if the home directory, and you are not already there, `cd` alone will work).
If you are prompted that the authenticity of the host cannot be established,
it is probably ok to input `yes[Enter]` to accept:

```
git clone git@github.com:rubyforgood/casa.git
cd casa

# If any of the below fail, execute them one at a time if you need to, to identify which one failed:
bundle && yarn && bundle exec rails db:setup && bundle exec rails webpacker:compile
```

Run the tests and/or the server!:

```
bundle exec rails spec               # run the tests

bundle exec rails server             # run the server
# or 
bundle exec rails server -b 0.0.0.0  # run the server
```

If the tests all pass and you can access the running Rails server from the host OS,
then your installation is successful.
