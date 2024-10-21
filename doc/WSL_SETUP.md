This guide will walk you through setting up the neccessary environment using  [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux), which will allow you to run Ubuntu on your Windows machine.

You will need the following local tools installed:

1. WSL
2. Ruby
3. NodeJs (optional)
4. Postgres
5. Google Chrome

### WSL (Windows Subsystem for Linux)

1. **Install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)**.

   `wsl --install`

   The above command only works if WSL is not installed at all, if you run `wsl --install `and see the WSL help text, do `--install -d Ubuntu`

2. **Run Ubuntu on Windows**

   You can run Ubuntu on Windows [several different ways](https://docs.microsoft.com/en-us/windows/wsl/install#ways-to-run-multiple-linux-distributions-with-wsl), but we suggest using [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install).

   To open an Ubuntu tab in Terminal, click the downward arrow and choose 'Ubuntu'.

   The following commands should all be run in an Ubuntu window.

### Ruby

Install a ruby version manager like [rbenv](https://github.com/rbenv/rbenv#installation)

  **Be sure to install the ruby version in `.ruby-version`. Right now that's Ruby 3.2.4.**

Instructions for rbenv:

1. **Install rbenv**

   `sudo apt install rbenv`

2. **Set up rbenv in your shell**

   `rbenv init`

3. **Close your Terminal window and open a new one so your changes take effect.**

4. **Verify that rbenv is properly set up**

   `curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-doctor | bash`

5.  **[Install Ruby](https://github.com/rbenv/rbenv#installing-ruby-versions)**

      **Be sure to install the ruby version in `.ruby-version`. Right now that's Ruby 3.2.4.**

      `rbenv install 3.2.4`

6. **Set a Ruby version to finish installation and start**

    `rbenv global 3.2.4` OR `rbenv local 3.2.4`

#### Troubleshooting
    If you are on Ubuntu in Windows Subsystem for Linux (WSL) and `rbenv install` indicates that the Ruby version is unavailable, you might be using Ubuntu's default install of `ruby-build`, which only comes with old installs of Ruby (ending before 2.6.) You should uninstall rvm and ruby-build's apt packages (`apt remove rvm ruby-build`) and install them with Git like this:

    - `git clone https://github.com/rbenv/rbenv.git ~/.rbenv`
    - `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
    - `echo 'eval "$(rbenv init -)"' >> ~/.bashrc`
    - `exec $SHELL`
    - `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`

    You'll probably hit a problem where ruby-version reads `ruby-2.7.2` but the install available to you is called `2.7.2`. If you do, install [rbenv-alias](https://github.com/tpope/rbenv-aliases) and create an alias between the two.

### NodeJS

The Casa package frontend leverages several javascript packages managed through `yarn`, so if you are working on those elements you will want to have node, npm, and yarn installed.

1. **(Recommended) [Install nvm](https://github.com/nvm-sh/nvm#installing-and-updating)**

   NVM is a node version manager.

2. **[Install yarn](https://classic.yarnpkg.com/en/docs/install)**

   Expand 'Alternatives' and select 'Debian/Ubuntu' for detailed instructions.

   `curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -`

   `echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list`

   `sudo apt update`

   `sudo apt install yarn`

### Postgres

1. **[Install PostgresSQL](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql) for WSL**

   `sudo apt install postgresql postgresql-contrib` - install

   `psql --version` - confirm installation and see version number

 2. **Install libpq-dev library**

      `sudo apt-get install libpq-dev`

3. **Start your postgresql service**

   `sudo service postgresql start`


### Google Chrome

Many of the frontend tests are run using Google Chrome, so if you don't already have that installed you may wish to install it.

For some linux distributions, installing `chromium-browser` may be enough on WSL. However, some versions of Ubuntu may require the chromium snap to be installed in order to use chromium.
If you receive errors about needing the chromium snap while running the test suite, you can install Chrome and chromedriver instead:

1. Download and Install Chrome on WSL Ubuntu
  - Update your packages:

    `sudo apt update`

  - Download Chrome:

    `wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb`

  - Install chrome from the downloaded file

    `sudo dpkg -i google-chrome-stable_current_amd64.deb`

    `sudo apt-get install -f`

  - Check that Chrome is installed correctly

    `google-chrome --version`

2. Install the appropriate Chromedriver
  - Depending on the version of google-chrome you installed, you will need a specific chromedriver. You can see which version you need on the [chromedriver dowload page](https://chromedriver.chromium.org/downloads).
    - For example, if `google-chrome --version` returns 105.x.xxxx.xxx you will want to download the version of chromedriver recommended on the page for version 105.
    - As of this writing, the download page says the following for Chrome version 105:
      > If you are using Chrome version 105, please download ChromeDriver 105.0.5195.52
  - To download chromedriver, run the following command, replacing `{CHROMEDRIVER-VERSION}` with the version of chromedriver you need (e.g., 105.0.5195.52)

    `wget https://chromedriver.storage.googleapis.com/{CHROMEDRIVER-VERSION}/chromedriver_linux64.zip`

  - Next, unzip the file you downloaded

    `unzip chromedriver_linux64.zip`

  - Finally, move chromedriver to the correct location and enable it for use:

    `sudo mv chromedriver /usr/bin/chromedriver`

    `sudo chown root:root /usr/bin/chromedriver`

    `sudo chmod +x /usr/bin/chromedriver`

3. Run the test suite
  - Assuming the rest of the application is already set up, you can run the test suite to verify that you no longer receive error regarding chromium snap:
    `bin/rails spec`

### Casa & Rails

Casa's install will also install the correct version of Rails.

1. **Download the project**

   **You should create a fork in GitHub if you don't have permission to directly commit to this repo. See our [contributing guide](https://github.com/rubyforgood/casa/blob/main/doc/CONTRIBUTING.md) for more detailed instructions.**

   `git clone <git address>` - use your fork's address if you have one

   ie

   `git clone https://github.com/rubyforgood/casa.git`

2. **Installing Packages**

   `cd casa/`

   `bundle install` -  install ruby dependencies.

   `yarn` - install javascript dependencies.

3. **Database Setup**

   Be sure your postgres service is running (`sudo service postgresql start`).

   Create a postgres user that matches your Ubuntu user:

   `sudo -u postgres createuser <username>` - create user

   `sudo -u postgres psql` - logs in as the postgres user

   `psql=# alter user <username> with encrypted password '<password>';` - add password

   `psql=# alter user <username> CREATEDB;` - give permission to your user to create databases

   Set up the Casa DB

    `bin/rails db:setup`  - sets up the db

    `bin/rails db:seed:replant` - generates test data (can be rerun to regenerate test data)
4. **Compile Assets**
-  `yarn build` compile javascript
&ensp;&ensp;`yarn build:dev` to auto recompile for when you edit js files
-  `yarn build:css` compile css
&ensp;&ensp;`yarn build:css:dev` to auto recompile for when you edit sass files

### Getting Started

See [Running the App / Verifying Installation](https://github.com/rubyforgood/casa#running-the-app--verifying-installation).

A good option for editing files in WSL is [Visual Studio Code Remote- WSL](https://code.visualstudio.com/docs/remote/wsl)
